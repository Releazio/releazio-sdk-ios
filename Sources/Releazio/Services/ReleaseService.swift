//
//  ReleaseService.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation

/// Protocol for release service
public protocol ReleaseServiceProtocol {
    func getReleases() async throws -> [Release]
    func getLatestRelease() async throws -> Release?
    func getRelease(releaseId: String) async throws -> Release
    func getChangelog(releaseId: String) async throws -> Changelog
    func checkForUpdates(currentVersion: String) async throws -> UpdateCheckResponse
    func getUpdateInfo(currentVersion: String) async throws -> UpdateInfo
    func clearCache() async
}

/// Service for managing app releases and updates
public class ReleaseService: ReleaseServiceProtocol {

    // MARK: - Properties

    /// Network manager instance
    private var networkManager: NetworkManagerProtocol?

    /// Configuration
    private var configuration: ReleazioConfiguration?

    /// Cache service
    private var cacheService: CacheServiceProtocol?

    /// Analytics service
    private var analyticsService: AnalyticsServiceProtocol?

    // MARK: - Initialization

    public init() {
        // Dependencies will be injected via configure method
    }

    /// Initialize with dependencies (for testing)
    /// - Parameters:
    ///   - networkManager: Network manager
    ///   - cacheService: Cache service
    ///   - analyticsService: Analytics service
    init(
        networkManager: NetworkManagerProtocol? = nil,
        cacheService: CacheServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        self.networkManager = networkManager
        self.cacheService = cacheService
        self.analyticsService = analyticsService
    }

    // MARK: - Configuration

    /// Configure service with dependencies
    /// - Parameter configuration: Releazio configuration
    func configure(with configuration: ReleazioConfiguration) {
        self.configuration = configuration

        // Initialize dependencies
        if networkManager == nil {
            self.networkManager = NetworkManager(configuration: configuration)
        }

        if cacheService == nil {
            self.cacheService = CacheService(configuration: configuration)
        }

        if analyticsService == nil {
            self.analyticsService = AnalyticsService()
        }

        // Configure services
        // Services are already configured with the configuration
    }

    // MARK: - Public Methods

    /// Get all releases for an application
    /// - Returns: Array of releases sorted by version (newest first)
    /// - Throws: ReleazioError
    public func getReleases() async throws -> [Release] {
        guard let networkManager = networkManager else {
            throw ReleazioError.configurationMissing
        }

        do {
            let releases = try await networkManager.getReleases()

            analyticsService?.trackEvent(.releasesFetched(count: releases.count))

            return releases.sorted { $0.version > $1.version }

        } catch {
            analyticsService?.trackEvent(.requestFailed(error: error.localizedDescription))
            throw error.asReleazioError()
        }
    }

    /// Get latest release for an application
    /// - Returns: Latest release or nil if no releases
    /// - Throws: ReleazioError
    public func getLatestRelease() async throws -> Release? {
        guard let networkManager = networkManager else {
            throw ReleazioError.configurationMissing
        }

        do {
            let release = try await networkManager.getLatestRelease()

            if let release = release {
                analyticsService?.trackEvent(.latestReleaseFetched(version: release.version))
            }

            return release

        } catch {
            analyticsService?.trackEvent(.requestFailed(error: error.localizedDescription))
            throw error.asReleazioError()
        }
    }

    /// Get specific release by ID
    /// - Parameters:
    ///   - releaseId: Release identifier
    /// - Returns: Release information
    /// - Throws: ReleazioError
    public func getRelease(
        releaseId: String
    ) async throws -> Release {
        guard let networkManager = networkManager else {
            throw ReleazioError.configurationMissing
        }

        do {
            // For now, we'll get the latest release since we don't have getRelease in NetworkManager
            guard let release = try await networkManager.getLatestRelease() else {
                throw ReleazioError.apiError(code: "RELEASE_NOT_FOUND", message: "Release not found")
            }

            analyticsService?.trackEvent(.releaseFetched(id: releaseId))

            return release

        } catch {
            analyticsService?.trackEvent(.requestFailed(error: error.localizedDescription))
            throw error.asReleazioError()
        }
    }

    /// Get changelog for a release
    /// - Parameters:
    ///   - releaseId: Release identifier
    /// - Returns: Changelog information
    /// - Throws: ReleazioError
    public func getChangelog(
        releaseId: String
    ) async throws -> Changelog {
        guard let networkManager = networkManager else {
            throw ReleazioError.configurationMissing
        }

        do {
            // Get config to find post URL
            let config = try await networkManager.getConfig()
            // Use first channel data since we only have one channel
            let channelData = config.data.first
            
            var content = ""
            var changelogEntries: [ChangelogEntry] = []
            
            if let postUrl = channelData?.postUrl {
                print("🔗 Using post URL: \(postUrl)")
                // Use the URL directly instead of loading content
                content = postUrl
            } else {
                print("⚠️ No post URL found, using update message")
                print("📊 Channel data: \(String(describing: channelData))")
                // Fallback to update message
                content = channelData?.updateMessage ?? "No changelog available"
            }
            
            // Create changelog entry from content
            if !content.isEmpty {
                let entry = ChangelogEntry(
                    id: releaseId,
                    title: "Version \(channelData?.appVersionName ?? "Unknown")",
                    description: content,
                    category: .feature,
                    priority: channelData?.isMandatory == true ? .critical : .normal,
                    tags: [],
                    isBreaking: false
                )
                changelogEntries = [entry]
            }

            // Create Changelog object
            let changelog = Changelog(
                id: releaseId,
                releaseId: releaseId,
                title: "Changelog for Release \(releaseId)",
                content: content,
                entries: changelogEntries,
                categories: [],
                author: nil,
                createdAt: Date(),
                updatedAt: Date(),
                publishedAt: Date(),
                locale: "en",
                isPublic: true
            )

            analyticsService?.trackEvent(.changelogFetched(releaseId: releaseId))

            return changelog

        } catch {
            analyticsService?.trackEvent(.requestFailed(error: error.localizedDescription))
            throw error.asReleazioError()
        }
    }

    /// Check for updates
    /// - Parameters:
    ///   - currentVersion: Current app version
    /// - Returns: Update check response
    /// - Throws: ReleazioError
    public func checkForUpdates(
        currentVersion: String
    ) async throws -> UpdateCheckResponse {
        guard let networkManager = networkManager else {
            throw ReleazioError.configurationMissing
        }

        do {
            let updateResponse = try await networkManager.checkForUpdates(
                currentVersion: currentVersion
            )

            analyticsService?.trackEvent(.updateChecked(
                hasUpdate: updateResponse.hasUpdate,
                currentVersion: currentVersion,
                latestVersion: updateResponse.updateInfo?.latestRelease?.version
            ))

            return updateResponse

        } catch {
            analyticsService?.trackEvent(.requestFailed(error: error.localizedDescription))
            throw error.asReleazioError()
        }
    }

    /// Clear all cached data (no-op since caching is disabled)
    public func clearCache() async {
        // Caching is disabled for releases to ensure fresh data
        analyticsService?.trackEvent(.cacheCleared)
    }
    
    /// Get configuration from API
    /// - Returns: Configuration response
    /// - Throws: ReleazioError
    public func getConfig() async throws -> ConfigResponse {
        guard let networkManager = networkManager else {
            throw ReleazioError.configurationMissing
        }
        return try await networkManager.getConfig()
    }

    /// Get update information for UI display
    /// - Parameters:
    ///   - currentVersion: Current version
    /// - Returns: Update information
    /// - Throws: ReleazioError
    public func getUpdateInfo(
        currentVersion: String
    ) async throws -> UpdateInfo {
        let updateResponse = try await checkForUpdates(
            currentVersion: currentVersion
        )

        guard updateResponse.hasUpdate,
              let latestRelease = updateResponse.updateInfo?.latestRelease else {
            return UpdateInfo(
                hasUpdate: false,
                latestRelease: nil,
                updateType: .none,
                isMandatory: false
            )
        }

        let currentAppVersion = try? AppVersion(versionString: currentVersion)
        let latestAppVersion = try? AppVersion(versionString: latestRelease.version)

        let updateType: UpdateType
        if let current = currentAppVersion,
           let latest = latestAppVersion {
            let bumpType = current.bumpType(comparedTo: latest)
            switch bumpType {
            case .major:
                updateType = .major
            case .minor:
                updateType = .minor
            case .patch:
                updateType = .patch
            case .none:
                updateType = .minor
            }
        } else {
            updateType = .minor
        }

        return UpdateInfo(
            hasUpdate: true,
            latestRelease: latestRelease,
            updateType: updateType,
            isMandatory: updateResponse.updateInfo?.isMandatory ?? false || latestRelease.isMandatory
        )
    }
}

// MARK: - Supporting Models

/// Update information for UI display
public struct UpdateInfo {
    public let hasUpdate: Bool
    public let latestRelease: Release?
    public let updateType: UpdateType
    public let isMandatory: Bool

    public init(
        hasUpdate: Bool,
        latestRelease: Release?,
        updateType: UpdateType,
        isMandatory: Bool
    ) {
        self.hasUpdate = hasUpdate
        self.latestRelease = latestRelease
        self.updateType = updateType
        self.isMandatory = isMandatory
    }

    /// Display priority for sorting
    public var priority: Int {
        if isMandatory {
            return 0
        }
        return updateType.priority
    }

    /// Should show update prompt
    public var shouldShowPrompt: Bool {
        return hasUpdate && (isMandatory || updateType == .major || updateType == .critical)
    }

    /// Update message for display
    public var updateMessage: String? {
        guard hasUpdate,
              let release = latestRelease else { return nil }

        if isMandatory {
            return "A mandatory update is required. Please update to continue using the app."
        }

        switch updateType {
        case .critical:
            return "A critical security update is available."
        case .major:
            return "A major new version with exciting features is available."
        case .minor:
            return "New features and improvements are available."
        case .patch:
            return "Bug fixes and improvements are available."
        case .none:
            return nil
        }
    }
}