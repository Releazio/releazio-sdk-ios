//
//  AnalyticsService.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation

/// Protocol for analytics service
public protocol AnalyticsServiceProtocol {
    func trackEvent(_ event: AnalyticsEventType)
    func trackEvent(_ event: AnalyticsEventType, properties: [String: String])
    func flushEvents()
    func getEventCount() -> Int
}

/// Analytics events for tracking SDK usage
public enum AnalyticsEventType {
    case sdkInitialized
    case sdkReset
    case releasesFetched(count: Int)
    case latestReleaseFetched(version: String)
    case releaseFetched(id: String)
    case changelogFetched(releaseId: String)
    case updateChecked(hasUpdate: Bool, currentVersion: String?, latestVersion: String?)
    case updatePromptShown
    case updatePromptDismissed
    case updateStarted(version: String)
    case updateCompleted(version: String)
    case cacheHit(key: String)
    case cacheMiss(key: String)
    case cacheCleared
    case requestFailed(error: String)
    case uiComponentShown(component: String)
    case custom(name: String, properties: [String: String])

    // MARK: - Properties

    /// Event name
    public var name: String {
        switch self {
        case .sdkInitialized:
            return "sdk_initialized"
        case .sdkReset:
            return "sdk_reset"
        case .releasesFetched:
            return "releases_fetched"
        case .latestReleaseFetched:
            return "latest_release_fetched"
        case .releaseFetched:
            return "release_fetched"
        case .changelogFetched:
            return "changelog_fetched"
        case .updateChecked:
            return "update_checked"
        case .updatePromptShown:
            return "update_prompt_shown"
        case .updatePromptDismissed:
            return "update_prompt_dismissed"
        case .updateStarted:
            return "update_started"
        case .updateCompleted:
            return "update_completed"
        case .cacheHit:
            return "cache_hit"
        case .cacheMiss:
            return "cache_miss"
        case .cacheCleared:
            return "cache_cleared"
        case .requestFailed:
            return "request_failed"
        case .uiComponentShown:
            return "ui_component_shown"
        case .custom(let name, _):
            return name
        }
    }

    /// Event properties
    public var properties: [String: String] {
        switch self {
        case .sdkInitialized:
            return [:]
        case .sdkReset:
            return [:]
        case .releasesFetched(let count):
            return ["count": "\(count)"]
        case .latestReleaseFetched(let version):
            return ["version": version]
        case .releaseFetched(let id):
            return ["release_id": id]
        case .changelogFetched(let releaseId):
            return ["release_id": releaseId]
        case .updateChecked(let hasUpdate, let currentVersion, let latestVersion):
            var props: [String: String] = ["has_update": "\(hasUpdate)"]
            if let currentVersion = currentVersion {
                props["current_version"] = currentVersion
            }
            if let latestVersion = latestVersion {
                props["latest_version"] = latestVersion
            }
            return props
        case .updatePromptShown:
            return [:]
        case .updatePromptDismissed:
            return [:]
        case .updateStarted(let version):
            return ["version": version]
        case .updateCompleted(let version):
            return ["version": version]
        case .cacheHit(let key):
            return ["cache_key": key]
        case .cacheMiss(let key):
            return ["cache_key": key]
        case .cacheCleared:
            return [:]
        case .requestFailed(let error):
            return ["error": error]
        case .uiComponentShown(let component):
            return ["component": component]
        case .custom(_, let properties):
            return properties
        }
    }
}

/// Service for tracking analytics events
public class AnalyticsService: AnalyticsServiceProtocol {

    // MARK: - Properties

    /// Configuration
    private var configuration: ReleazioConfiguration?

    /// Network manager for sending events
    private var networkManager: NetworkManagerProtocol?

    /// Event queue for batching
    private var eventQueue: [AnalyticsEvent] = []

    /// Queue for thread-safe operations
    private let queue = DispatchQueue(label: "releazio.analytics", attributes: .concurrent)

    /// Timer for flushing events
    private var flushTimer: Timer?

    /// Maximum events to keep in queue
    private let maxQueueSize = 100

    /// Flush interval in seconds
    private let flushInterval: TimeInterval = 30

    // MARK: - Initialization

    public init() {
        // Dependencies will be injected via configure method
    }

    /// Initialize with dependencies (for testing)
    /// - Parameter networkManager: Network manager
    init(networkManager: NetworkManagerProtocol? = nil) {
        self.networkManager = networkManager
    }

    // MARK: - Configuration

    /// Configure analytics service
    /// - Parameter configuration: Releazio configuration
    func configure(with configuration: ReleazioConfiguration) {
        self.configuration = configuration

        // Initialize network manager
        if networkManager == nil {
            self.networkManager = NetworkManager(configuration: configuration)
        }

        // Start flush timer
        startFlushTimer()
    }

    // MARK: - Public Methods

    /// Track analytics event
    /// - Parameter event: Event type
    public func trackEvent(_ event: AnalyticsEventType) {
        trackEvent(event, properties: [:])
    }

    /// Track analytics event with additional properties
    /// - Parameters:
    ///   - event: Event type
    ///   - properties: Additional properties
    public func trackEvent(_ event: AnalyticsEventType, properties: [String: String]) {
        guard configuration?.analyticsEnabled == true else { return }

        let analyticsEvent = AnalyticsEvent(
            name: event.name,
            properties: event.properties.merging(properties) { _, new in new }
        )

        queue.async(flags: .barrier) {
            self.eventQueue.append(analyticsEvent)

            // Log if debug mode is enabled
            if self.configuration?.debugLoggingEnabled == true {
                print("📊 Analytics Event: \(analyticsEvent.name) - \(analyticsEvent.properties)")
            }

            // Flush if queue is full
            if self.eventQueue.count >= self.maxQueueSize {
                Task {
                    await self.flushEvents()
                }
            }
        }
    }

    /// Flush all queued events to the server
    public func flushEvents() {
        queue.async(flags: .barrier) {
            let events = Array(self.eventQueue)
            self.eventQueue.removeAll()

            if events.isEmpty { return }

            Task {
                await self.sendEvents(events)
            }
        }
    }

    /// Get number of queued events
    /// - Returns: Event count
    public func getEventCount() -> Int {
        return queue.sync {
            return eventQueue.count
        }
    }

    // MARK: - Private Methods

    /// Start automatic flush timer
    private func startFlushTimer() {
        flushTimer = Timer.scheduledTimer(withTimeInterval: flushInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.flushEvents()
            }
        }
    }

    /// Send events to server
    /// - Parameter events: Array of events to send
    private func sendEvents(_ events: [AnalyticsEvent]) async {
        guard let networkManager = networkManager,
              let configuration = configuration else { return }

        do {
            // Send events in batches
            let batchSize = 20
            for batch in events.chunked(into: batchSize) {
                for event in batch {
                    try await networkManager.trackEvent(
                        event: event
                    )
                }

                // Small delay between batches to avoid rate limiting
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }

            if configuration.debugLoggingEnabled {
                print("📊 Analytics: Sent \(events.count) events")
            }

        } catch {
            if configuration.debugLoggingEnabled {
                print("⚠️ Analytics: Failed to send events - \(error)")
            }

            // Re-queue failed events if it's a network error
            if case ReleazioError.networkError = error {
                queue.async(flags: .barrier) {
                    self.eventQueue.insert(contentsOf: events, at: 0)
                }
            }
        }
    }

    // MARK: - Deinitialization

    deinit {
        flushTimer?.invalidate()
        flushEvents()
    }
}

// MARK: - Array Extension

private extension Array {
    /// Split array into chunks of specified size
    /// - Parameter size: Chunk size
    /// - Returns: Array of array chunks
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Analytics Extensions

extension AnalyticsService {

    /// Track SDK initialization
    public func trackSDKInitialized() {
        trackEvent(.sdkInitialized)
    }

    /// Track SDK reset
    public func trackSDKReset() {
        trackEvent(.sdkReset)
    }

    /// Track releases fetch
    /// - Parameter count: Number of releases fetched
    public func trackReleasesFetched(count: Int) {
        trackEvent(.releasesFetched(count: count))
    }

    /// Track latest release fetch
    /// - Parameter version: Latest version
    public func trackLatestReleaseFetched(version: String) {
        trackEvent(.latestReleaseFetched(version: version))
    }

    /// Track release fetch
    /// - Parameter releaseId: Release ID
    public func trackReleaseFetched(id: String) {
        trackEvent(.releaseFetched(id: id))
    }

    /// Track changelog fetch
    /// - Parameter releaseId: Release ID
    public func trackChangelogFetched(releaseId: String) {
        trackEvent(.changelogFetched(releaseId: releaseId))
    }

    /// Track update check
    /// - Parameters:
    ///   - hasUpdate: Whether update is available
    ///   - currentVersion: Current version
    ///   - latestVersion: Latest version
    public func trackUpdateChecked(
        hasUpdate: Bool,
        currentVersion: String? = nil,
        latestVersion: String? = nil
    ) {
        trackEvent(.updateChecked(
            hasUpdate: hasUpdate,
            currentVersion: currentVersion,
            latestVersion: latestVersion
        ))
    }

    /// Track update prompt shown
    public func trackUpdatePromptShown() {
        trackEvent(.updatePromptShown)
    }

    /// Track update prompt dismissed
    public func trackUpdatePromptDismissed() {
        trackEvent(.updatePromptDismissed)
    }

    /// Track update started
    /// - Parameter version: Version being updated to
    public func trackUpdateStarted(version: String) {
        trackEvent(.updateStarted(version: version))
    }

    /// Track update completed
    /// - Parameter version: Updated version
    public func trackUpdateCompleted(version: String) {
        trackEvent(.updateCompleted(version: version))
    }

    /// Track cache hit
    /// - Parameter key: Cache key
    public func trackCacheHit(key: String) {
        trackEvent(.cacheHit(key: key))
    }

    /// Track cache miss
    /// - Parameter key: Cache key
    public func trackCacheMiss(key: String) {
        trackEvent(.cacheMiss(key: key))
    }

    /// Track cache cleared
    public func trackCacheCleared() {
        trackEvent(.cacheCleared)
    }

    /// Track request failure
    /// - Parameter error: Error description
    public func trackRequestFailed(error: String) {
        trackEvent(.requestFailed(error: error))
    }

    /// Track UI component shown
    /// - Parameter component: Component name
    public func trackUIComponentShown(component: String) {
        trackEvent(.uiComponentShown(component: component))
    }

    /// Track custom event
    /// - Parameters:
    ///   - name: Event name
    ///   - properties: Event properties
    public func trackCustomEvent(name: String, properties: [String: String] = [:]) {
        trackEvent(.custom(name: name, properties: properties))
    }
}