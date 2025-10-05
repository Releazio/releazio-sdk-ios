//
//  CacheService.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation

/// Cache item structure
public struct CacheItem: Codable {
    let data: Data
    let timestamp: Date
    let timeout: TimeInterval?

    var isExpired: Bool {
        guard let timeout = timeout else { return false }
        return Date().timeIntervalSince(timestamp) > timeout
    }

    init(data: Data, timeout: TimeInterval?) {
        self.data = data
        self.timestamp = Date()
        self.timeout = timeout
    }
}

/// Protocol for cache service
public protocol CacheServiceProtocol {
    func get<T: Codable>(_ type: T.Type, key: String) async throws -> T?
    func set<T: Codable>(_ value: T, key: String, timeout: TimeInterval?) async throws
    func remove(key: String) async throws
    func clearAll() async
    func getCacheSize() async -> Int64
}

/// Cache service for storing and retrieving data
public class CacheService: CacheServiceProtocol {

    // MARK: - Properties

    /// Configuration
    private var configuration: ReleazioConfiguration?

    /// Cache storage
    private let storage: CacheStorage

    /// Maximum cache size in bytes (default: 50MB)
    private let maxCacheSize: Int64 = 50 * 1024 * 1024

    /// Cache queue
    private let cacheQueue = DispatchQueue(label: "releazio.cache", attributes: .concurrent)

    /// In-memory cache for frequently accessed items
    private var memoryCache: [String: CacheItem] = [:]

    /// Maximum memory cache items
    private let maxMemoryCacheItems = 100


    // MARK: - Initialization

    public init(configuration: ReleazioConfiguration? = nil) {
        self.configuration = configuration
        self.storage = CacheStorage()

        // Clean expired items on initialization
        Task {
            await cleanExpiredItems()
        }
    }

    /// Initialize with custom storage (for testing)
    /// - Parameter storage: Custom cache storage
    fileprivate init(storage: CacheStorage) {
        self.storage = storage
    }

    // MARK: - Configuration

    /// Configure cache service
    /// - Parameter configuration: Releazio configuration
    func configure(with configuration: ReleazioConfiguration) {
        self.configuration = configuration
    }

    // MARK: - Public Methods

    /// Get cached value
    /// - Parameters:
    ///   - type: Type of value to decode
    ///   - key: Cache key
    /// - Returns: Cached value or nil if not found/expired
    /// - Throws: Decoding error
    public func get<T: Codable>(_ type: T.Type, key: String) async throws -> T? {
        // Check memory cache first
        if let memoryItem = memoryCache[key] {
            if !memoryItem.isExpired {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(type, from: memoryItem.data)
            } else {
                // Remove expired item from memory
                memoryCache.removeValue(forKey: key)
            }
        }

        // Check disk cache
        do {
            let cacheItem = try await storage.get(key: key)

            // Check if expired
            if cacheItem.isExpired {
                try? await storage.remove(key: key)
                return nil
            }

            // Decode the data
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let value = try decoder.decode(type, from: cacheItem.data)

            // Store in memory cache for faster access
            setInMemoryCache(key: key, item: cacheItem)

            return value

        } catch CacheStorageError.keyNotFound {
            return nil
        } catch {
            throw ReleazioError.cacheError(error)
        }
    }

    /// Set cached value
    /// - Parameters:
    ///   - value: Value to cache
    ///   - key: Cache key
    ///   - timeout: Cache timeout in seconds (optional)
    /// - Throws: Encoding error
    public func set<T: Codable>(_ value: T, key: String, timeout: TimeInterval?) async throws {
        let timeout = timeout ?? configuration?.cacheExpirationTime

        // Encode the value
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(value)

        // Create cache item
        let cacheItem = CacheItem(data: data, timeout: timeout)

        // Store in memory cache
        setInMemoryCache(key: key, item: cacheItem)

        // Store in disk cache
        do {
            try await storage.set(key: key, item: cacheItem)

            // Check cache size and clean if necessary
            await checkAndCleanCache()

        } catch {
            throw ReleazioError.cacheError(error)
        }
    }

    /// Remove cached value
    /// - Parameter key: Cache key
    /// - Throws: Cache error
    public func remove(key: String) async throws {
        // Remove from memory cache
        memoryCache.removeValue(forKey: key)

        // Remove from disk cache
        do {
            try await storage.remove(key: key)
        } catch {
            throw ReleazioError.cacheError(error)
        }
    }

    /// Clear all cached data
    public func clearAll() async {
        // Clear memory cache
        memoryCache.removeAll()

        // Clear disk cache
        do {
            try await storage.clearAll()
        } catch {
            if configuration?.debugLoggingEnabled == true {
                print("⚠️ Failed to clear disk cache: \(error)")
            }
        }
    }

    /// Get current cache size in bytes
    /// - Returns: Cache size
    public func getCacheSize() async -> Int64 {
        do {
            return try await storage.getSize()
        } catch {
            return 0
        }
    }

    // MARK: - Private Methods

    /// Set item in memory cache
    /// - Parameters:
    ///   - key: Cache key
    ///   - item: Cache item
    private func setInMemoryCache(key: String, item: CacheItem) {
        cacheQueue.async(flags: .barrier) {
            self.memoryCache[key] = item

            // Remove oldest items if memory cache is full
            if self.memoryCache.count > self.maxMemoryCacheItems {
                let sortedItems = self.memoryCache.sorted {
                    $0.value.timestamp < $1.value.timestamp
                }
                let itemsToRemove = sortedItems.prefix(
                    self.memoryCache.count - self.maxMemoryCacheItems
                )
                for (key, _) in itemsToRemove {
                    self.memoryCache.removeValue(forKey: key)
                }
            }
        }
    }

    /// Clean expired items
    private func cleanExpiredItems() async {
        // Clean memory cache
        cacheQueue.async(flags: .barrier) {
            let expiredKeys = self.memoryCache.compactMap { key, item in
                item.isExpired ? key : nil
            }

            for key in expiredKeys {
                self.memoryCache.removeValue(forKey: key)
            }
        }

        // Clean disk cache
        do {
            try await storage.cleanExpired()
        } catch {
            if configuration?.debugLoggingEnabled == true {
                print("⚠️ Failed to clean expired items: \(error)")
            }
        }
    }

    /// Check cache size and clean if necessary
    private func checkAndCleanCache() async {
        do {
            let currentSize = try await storage.getSize()

            if currentSize > maxCacheSize {
                try await storage.cleanToSize(maxCacheSize)
            }
        } catch {
            if configuration?.debugLoggingEnabled == true {
                print("⚠️ Failed to check cache size: \(error)")
            }
        }
    }
}

// MARK: - Cache Storage

/// Cache storage implementation using UserDefaults and FileManager
private class CacheStorage {

    // MARK: - Properties

    /// Cache directory
    private let cacheDirectory: URL

    /// UserDefaults for metadata
    private let userDefaults: UserDefaults

    /// Cache metadata key
    private let metadataKey = "releazio_cache_metadata"

    // MARK: - Initialization

    init() {
        // Create cache directory
        let fileManager = FileManager.default
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheDirectory = cachesDirectory.appendingPathComponent("Releazio")

        // Create directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        self.userDefaults = UserDefaults.standard
    }

    // MARK: - Public Methods

    /// Get cache item
    /// - Parameter key: Cache key
    /// - Returns: Cache item
    /// - Throws: CacheStorageError
    func get(key: String) async throws -> CacheItem {
        let fileURL = cacheDirectory.appendingPathComponent(key.hashDescription)

        do {
            let data = try Data(contentsOf: fileURL)
            let cacheItem = try JSONDecoder().decode(CacheItem.self, from: data)
            return cacheItem
        } catch CocoaError.fileReadNoSuchFile {
            throw CacheStorageError.keyNotFound
        } catch {
            throw CacheStorageError.readError(error)
        }
    }

    /// Set cache item
    /// - Parameters:
    ///   - key: Cache key
    ///   - item: Cache item
    /// - Throws: CacheStorageError
    func set(key: String, item: CacheItem) async throws {
        let fileURL = cacheDirectory.appendingPathComponent(key.hashDescription)

        do {
            let data = try JSONEncoder().encode(item)
            try data.write(to: fileURL)

            // Update metadata
            updateMetadata(key: key, size: Int64(data.count))
        } catch {
            throw CacheStorageError.writeError(error)
        }
    }

    /// Remove cache item
    /// - Parameter key: Cache key
    /// - Throws: CacheStorageError
    func remove(key: String) async throws {
        let fileURL = cacheDirectory.appendingPathComponent(key.hashDescription)

        do {
            try FileManager.default.removeItem(at: fileURL)
            removeMetadata(key: key)
        } catch CocoaError.fileNoSuchFile {
            // Item doesn't exist, ignore
        } catch {
            throw CacheStorageError.deleteError(error)
        }
    }

    /// Clear all cache
    /// - Throws: CacheStorageError
    func clearAll() async throws {
        do {
            try FileManager.default.removeItem(at: cacheDirectory)
            try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

            // Clear metadata
            userDefaults.removeObject(forKey: metadataKey)
        } catch {
            throw CacheStorageError.deleteError(error)
        }
    }

    /// Get total cache size
    /// - Returns: Size in bytes
    /// - Throws: CacheStorageError
    func getSize() async throws -> Int64 {
        let metadata = getMetadata()
        return metadata.values.reduce(0, +)
    }

    /// Clean expired items
    /// - Throws: CacheStorageError
    func cleanExpired() async throws {
        let metadata = getMetadata()
        var expiredKeys: [String] = []
        for (key, _) in metadata {
            do {
                let item = try await get(key: key)
                if item.isExpired {
                    expiredKeys.append(key)
                }
            } catch {
                // Remove items that can't be read
                expiredKeys.append(key)
            }
        }

        for key in expiredKeys {
            try? await remove(key: key)
        }
    }

    /// Clean cache to specific size
    /// - Parameter targetSize: Target size in bytes
    /// - Throws: CacheStorageError
    func cleanToSize(_ targetSize: Int64) async throws {
        let metadata = getMetadata()
        let currentSize = metadata.values.reduce(0, +)

        guard currentSize > targetSize else { return }

        // Get all items with their timestamps
        var itemsWithTimestamps: [(key: String, timestamp: Date)] = []

        for (key, _) in metadata {
            do {
                let item = try await get(key: key)
                itemsWithTimestamps.append((key: key, timestamp: item.timestamp))
            } catch {
                // Remove items that can't be read
                try? await remove(key: key)
            }
        }

        // Sort by timestamp (oldest first) and remove until target size is reached
        itemsWithTimestamps.sort { $0.timestamp < $1.timestamp }

        var sizeToRemove = currentSize - targetSize

        for item in itemsWithTimestamps {
            if sizeToRemove <= 0 { break }

            let itemSize = metadata[item.key] ?? 0
            try? await remove(key: item.key)
            sizeToRemove -= itemSize
        }
    }

    // MARK: - Private Methods

    /// Get cache metadata
    /// - Returns: Metadata dictionary
    private func getMetadata() -> [String: Int64] {
        return userDefaults.dictionary(forKey: metadataKey) as? [String: Int64] ?? [:]
    }

    /// Update cache metadata
    /// - Parameters:
    ///   - key: Cache key
    ///   - size: Item size
    private func updateMetadata(key: String, size: Int64) {
        var metadata = getMetadata()
        metadata[key] = size
        userDefaults.set(metadata, forKey: metadataKey)
    }

    /// Remove cache metadata
    /// - Parameter key: Cache key
    private func removeMetadata(key: String) {
        var metadata = getMetadata()
        metadata.removeValue(forKey: key)
        userDefaults.set(metadata, forKey: metadataKey)
    }
}

// MARK: - Cache Storage Errors

enum CacheStorageError: Error {
    case keyNotFound
    case readError(Error)
    case writeError(Error)
    case deleteError(Error)
}

// MARK: - String + Hash Extension

private extension String {
    var hashDescription: String {
        return self.sha256
    }

    var sha256: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { bytes in
            return bytes.bindMemory(to: UInt8.self)
        }

        // Simple hash implementation for cache keys
        // In production, you might want to use CommonCrypto or CryptoKit
        return String(format: "%02x", self.hashValue)
    }
}