//
//  NetworkManager.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Protocol for network manager
public protocol NetworkManagerProtocol {
    func getConfig() async throws -> ConfigResponse
    func getReleases() async throws -> [Release]
    func getLatestRelease() async throws -> Release?
    func getChangelog() async throws -> [ChangelogEntry]
    func getPostContent(from url: String) async throws -> String
    func checkForUpdates(currentVersion: String) async throws -> UpdateCheckResponse
    func trackEvent(event: AnalyticsEvent) async throws
    func validateAPIKey() async throws -> Bool
    func sendDeviceInit() async throws
}

/// Network manager for coordinating API requests
public class NetworkManager: NetworkManagerProtocol {

    // MARK: - Properties

    /// Network client instance
    private let networkClient: NetworkClientProtocol

    /// Configuration
    private let configuration: ReleazioConfiguration

    /// Request cache for handling concurrent requests
    private var requestCache: [String: Task<Any, Error>] = [:]
    private let cacheQueue = DispatchQueue(label: "releazio.network.cache", attributes: .concurrent)

    // MARK: - Initialization

    /// Initialize network manager
    /// - Parameters:
    ///   - configuration: Releazio configuration
    ///   - networkClient: Network client (optional, for testing)
    init(configuration: ReleazioConfiguration, networkClient: NetworkClientProtocol? = nil) {
        self.configuration = configuration
        self.networkClient = networkClient ?? NetworkClient(configuration: configuration)
    }

    // MARK: - Public Methods

    /// Get application configuration
    /// - Returns: Configuration response
    /// - Throws: ReleazioError
    public func getConfig() async throws -> ConfigResponse {
        // Collect all parameters from Bundle and system
        let channel = "appstore" // iOS always uses App Store
        let appId = Bundle.main.bundleIdentifier
        let appVersionCode = Bundle.main.buildVersion
        let appVersionName = Bundle.main.appVersion?.versionString
        let phoneLocaleCountry = Locale.current.regionCode
        let phoneLocaleLanguage = Locale.current.languageCode
        let osVersionCode = ProcessInfo.processInfo.operatingSystemVersion.majorVersion
        let deviceManufacturer = "Apple"
        let deviceBrand = "Apple"
        
        #if canImport(UIKit)
        let deviceModel = UIDevice.current.model
        #else
        let deviceModel: String? = nil
        #endif
        
        let endpoint = APIEndpoints.getConfig(
            channel: channel,
            appId: appId,
            appVersionCode: appVersionCode,
            appVersionName: appVersionName,
            phoneLocaleCountry: phoneLocaleCountry,
            phoneLocaleLanguage: phoneLocaleLanguage,
            osVersionCode: osVersionCode,
            deviceManufacturer: deviceManufacturer,
            deviceBrand: deviceBrand,
            deviceModel: deviceModel
        )

        do {
            let request = APIRequest.get(
                url: endpoint,
                headers: defaultHeaders(),
                timeout: configuration.networkTimeout
            )
            let response: ConfigResponse = try await networkClient.request(request)
            return response
        } catch {
            throw error.asReleazioError()
        }
    }

    /// Get all releases for an application (extracted from config)
    /// - Returns: Array of releases
    /// - Throws: ReleazioError
    public func getReleases() async throws -> [Release] {
        let config = try await getConfig()
        
        // Convert channel data to releases
        return config.data.compactMap { channelData in
            Release(
                id: channelData.channel,
                version: channelData.appVersionName,
                buildNumber: channelData.appVersionCode,
                title: "Version \(channelData.appVersionName)",
                description: channelData.updateMessage.isEmpty ? nil : channelData.updateMessage,
                releaseNotes: channelData.updateMessage.isEmpty ? nil : channelData.updateMessage,
                releaseDate: Date(),
                isMandatory: channelData.isMandatory,
                downloadURL: channelData.primaryDownloadUrl
            )
        }
    }

    /// Get latest release for an application (extracted from config)
    /// - Returns: Latest release or nil if no releases
    /// - Throws: ReleazioError
    public func getLatestRelease() async throws -> Release? {
        let releases = try await getReleases()
        return releases.first
    }

    /// Get changelog for an application (extracted from config)
    /// - Returns: Array of changelog entries
    /// - Throws: ReleazioError
    public func getChangelog() async throws -> [ChangelogEntry] {
        let config = try await getConfig()
        
        // Convert channel data to changelog entries
        return config.data.compactMap { channelData -> ChangelogEntry? in
            guard !channelData.updateMessage.isEmpty else { return nil }
            
            return ChangelogEntry(
                id: channelData.channel,
                title: "Version \(channelData.appVersionName)",
                description: channelData.updateMessage,
                category: .feature,
                priority: channelData.isMandatory ? .critical : .normal,
                tags: [],
                isBreaking: false
            )
        }
    }
    
    /// Get post content from URL
    /// - Parameter url: Post URL
    /// - Returns: Post content as string
    /// - Throws: ReleazioError
    public func getPostContent(from url: String) async throws -> String {
        guard let postURL = URL(string: url) else {
            throw ReleazioError.invalidURL(url)
        }
        
        do {
            let request = APIRequest.get(
                url: postURL,
                headers: defaultHeaders(),
                timeout: configuration.networkTimeout
            )
            let response: APIResponse<String> = try await networkClient.request(request)
            return try response.unwrap()
        } catch {
            throw error.asReleazioError()
        }
    }

    /// Check for updates (extracted from config)
    /// - Parameters:
    ///   - currentVersion: Current app version
    /// - Returns: Update check response
    /// - Throws: ReleazioError
    public func checkForUpdates(
        currentVersion: String
    ) async throws -> UpdateCheckResponse {
        let config = try await getConfig()
        
        // Find the first channel data (usually App Store)
        guard let channelData = config.data.first else {
            return UpdateCheckResponse(
                hasUpdate: false,
                updateInfo: nil,
                maintenanceMode: false,
                maintenanceMessage: nil
            )
        }
        
        let hasUpdate = channelData.hasUpdate
        let isMandatory = channelData.isMandatory
        
        // Determine update type based on update_type from API
        let updateType: UpdateType
        switch channelData.updateType {
        case 0:
            updateType = .none
        case 1:
            updateType = .minor
        case 2:
            updateType = .major
        default:
            updateType = .minor
        }
        
        // Create release object for update info
        let latestRelease = Release(
            id: channelData.channel,
            version: channelData.appVersionName,
            buildNumber: channelData.appVersionCode,
            title: "Version \(channelData.appVersionName)",
            description: channelData.updateMessage.isEmpty ? nil : channelData.updateMessage,
            releaseNotes: channelData.updateMessage.isEmpty ? nil : channelData.updateMessage,
            releaseDate: Date(),
            isMandatory: isMandatory,
            downloadURL: channelData.primaryDownloadUrl
        )
        
        let updateInfo = UpdateInfo(
            hasUpdate: hasUpdate,
            latestRelease: latestRelease,
            updateType: updateType,
            isMandatory: isMandatory
        )
        
        return UpdateCheckResponse(
            hasUpdate: hasUpdate,
            updateInfo: updateInfo,
            maintenanceMode: false,
            maintenanceMessage: nil
        )
    }

    /// Track analytics event
    /// - Parameters:
    ///   - event: Analytics event
    /// - Throws: ReleazioError
    public func trackEvent(event: AnalyticsEvent) async throws {
        // For now, we'll just log the event if debug mode is enabled
        if configuration.debugLoggingEnabled {
            print("📊 Analytics Event: \(event.name) - \(event.properties)")
        }
    }

    /// Send device initialization request to server (POST /init)
    /// - Throws: ReleazioError if network request fails
    public func sendDeviceInit() async throws {
        // Collect all device information
        let channel = "appstore" // iOS always uses App Store
        let appId = Bundle.main.bundleIdentifier
        let appVersionCode = Bundle.main.buildVersion
        let appVersionName = Bundle.main.appVersion?.versionString
        let osType = "ios"
        let region = Locale.current.regionCode
        let marketPackages: String? = nil // Not applicable for iOS
        let locale = Locale.current.languageCode
        let osVersionCode = String(ProcessInfo.processInfo.operatingSystemVersion.majorVersion)
        let deviceManufacturer = "Apple"
        let deviceBrand = "Apple"
        
        #if canImport(UIKit)
        let deviceModel = UIDevice.current.model
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        
        // Get screen dimensions
        let screen = UIScreen.main
        let screenWidth = Int(screen.bounds.width)
        let screenHeight = Int(screen.bounds.height)
        let screenScale = Int(screen.scale)
        
        // Check if running on simulator
        #if targetEnvironment(simulator)
        let isEmulator = true
        #else
        let isEmulator = false
        #endif
        #else
        let deviceModel: String? = nil
        let deviceId: String? = nil
        let screenWidth: Int? = nil
        let screenHeight: Int? = nil
        let screenScale: Int? = nil
        let isEmulator: Bool? = nil
        #endif
        
        let timezone = TimeZone.current.identifier
        let sdkVersion = "1.0.9" // SDK version
        let osApiLevel: String? = nil // Not applicable for iOS
        
        // Create InitRequest
        let initRequest = InitRequest(
            channel: channel,
            appId: appId,
            appVersionCode: appVersionCode,
            appVersionName: appVersionName,
            osType: osType,
            region: region,
            marketPackages: marketPackages,
            locale: locale,
            osVersionCode: osVersionCode,
            deviceManufacturer: deviceManufacturer,
            deviceBrand: deviceBrand,
            deviceModel: deviceModel,
            sdkVersion: sdkVersion,
            osApiLevel: osApiLevel,
            timezone: timezone,
            deviceId: deviceId,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            screenScale: screenScale,
            isEmulator: isEmulator
        )
        
        // Encode to JSON
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(initRequest)
        
        // Create POST request
        let endpoint = APIEndpoints.initEndpoint()
        let request = APIRequest.post(
            url: endpoint,
            body: jsonData,
            headers: defaultHeaders(),
            timeout: configuration.networkTimeout
        )
        
        // Send request (response may be empty 200 OK)
        try await networkClient.requestEmpty(request)
    }
    
    /// Validate API key
    /// - Returns: True if API key is valid
    /// - Throws: ReleazioError if network request fails
    public func validateAPIKey() async throws -> Bool {
        // For now, we'll consider API key valid if we can successfully get config
        do {
            let _ = try await getConfig()
            return true
        } catch {
            return false
        }
    }

    // MARK: - Private Methods
    
    /// Get default headers for all requests
    /// - Returns: Default headers dictionary (only Authorization header)
    private func defaultHeaders() -> [String: String] {
        var headers: [String: String] = [
            "Accept": "application/json"
        ]

        // Add API key if available
        headers["Authorization"] = configuration.apiKey

        return headers
    }

    /// Execute request with caching to prevent duplicate concurrent requests
    /// - Parameters:
    ///   - key: Cache key
    ///   - cacheTimeout: Cache timeout in seconds (default: use configuration)
    ///   - operation: Async operation to execute
    /// - Returns: Result of the operation
    private func withCaching<T>(
        key: String,
        cacheTimeout: TimeInterval? = nil,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        // Check if we already have a running request for this key
        if let existingTask = requestCache[key] {
            return try await existingTask.value as! T
        }

        // Create new task
        let task = Task<Any, Error> { [self] in
            do {
                let result = try await operation()
                return result
            } catch {
                // Clean up cache when done (on error)
                self.cacheQueue.async(flags: .barrier) {
                    self.requestCache.removeValue(forKey: key)
                }
                throw error
            }
        }

        cacheQueue.async(flags: .barrier) {
            self.requestCache[key] = task
        }

        do {
            let result = try await task.value
            // Clean up cache when done (on success)
            cacheQueue.async(flags: .barrier) {
                self.requestCache.removeValue(forKey: key)
            }
            return result as! T
        } catch {
            // Clean up on error (already handled above, but ensure cleanup)
            cacheQueue.async(flags: .barrier) {
                self.requestCache.removeValue(forKey: key)
            }
            throw error
        }
    }
}

// MARK: - NetworkManager Extensions

extension NetworkManager {
    
    /// Get device information for analytics
    /// - Returns: Device information
    public struct DeviceInfo: Codable {
        public let platform: String
        public let osVersion: String
        public let appVersion: String
        public let buildNumber: String
        public let deviceModel: String
        public let locale: String

        public static var current: DeviceInfo {
            #if canImport(UIKit)
            let deviceModel = UIDevice.current.model
            #else
            let deviceModel = "Unknown"
            #endif
            return DeviceInfo(
                platform: "iOS",
                osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
                appVersion: Bundle.main.appVersion?.versionString ?? "unknown",
                buildNumber: Bundle.main.buildVersion ?? "unknown",
                deviceModel: deviceModel,
                locale: Locale.current.identifier
            )
        }
    }
}
