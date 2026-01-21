//
//  Releazio.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Main entry point for Releazio iOS SDK
public class Releazio {

    // MARK: - Singleton

    /// Shared instance of Releazio SDK
    public static let shared = Releazio()

    // MARK: - Properties

    /// Configuration for the SDK
    private var configuration: ReleazioConfiguration?

    /// Release service for managing releases
    private lazy var releaseService = ReleaseService()

    /// Analytics service for tracking SDK usage
    private lazy var analyticsService = AnalyticsService()
    
    /// Update state manager
    private lazy var updateStateManager = UpdateStateManager()

    // MARK: - Initialization

    private init() {}

    // MARK: - Public API

    /// Configure Releazio SDK with provided configuration
    /// - Parameter configuration: The configuration object containing API key and other settings
    public static func configure(with configuration: ReleazioConfiguration) {
        shared.configuration = configuration
        shared.setupServices()

        // Track SDK initialization
        shared.analyticsService.trackEvent(.sdkInitialized)
        
        // Call sendDeviceInit() to send device info to server (fire-and-forget)
        Task {
            do {
                try await shared.releaseService.sendDeviceInit()
            } catch {
                // Log error, but don't interrupt initialization
                if configuration.debugLoggingEnabled {
                    print("⚠️ Failed to call sendDeviceInit: \(error)")
                }
            }
        }
    }

    /// Check for available updates
    /// - Returns: Boolean indicating if updates are available
    /// - Throws: ReleazioError if configuration is missing or network request fails
    @available(*, deprecated, message: "Use checkUpdates() instead. This method only returns a boolean and doesn't provide full update state information.")
    public func checkForUpdates() async throws -> Bool {
        guard configuration != nil else {
            throw ReleazioError.configurationMissing
        }

        let releases = try await releaseService.getReleases()

        guard let currentVersion = Bundle.main.appVersion else {
            return false
        }
        let hasUpdate = releases.contains { release in
            guard let releaseVersion = try? AppVersion(versionString: release.version) else { return false }
            return releaseVersion > currentVersion
        }

        if hasUpdate {
            analyticsService.trackEvent(.updateChecked(hasUpdate: true, currentVersion: currentVersion.versionString, latestVersion: releases.first?.version))
        }

        return hasUpdate
    }

    /// Get all releases
    /// - Returns: Array of releases
    /// - Throws: ReleazioError if configuration is missing or network request fails
    @available(*, deprecated, message: "This method is deprecated. Use checkUpdates() to get update state with full channel data.")
    public func getReleases() async throws -> [Release] {
        guard configuration != nil else {
            throw ReleazioError.configurationMissing
        }

        return try await releaseService.getReleases()
    }
    
    /// Get configuration from API
    /// - Returns: Configuration response
    /// - Throws: ReleazioError
    public func getConfig() async throws -> ConfigResponse {
        guard configuration != nil else {
            throw ReleazioError.configurationMissing
        }
        return try await releaseService.getConfig()
    }

    /// Get latest release information
    /// - Returns: Latest release object or nil if no releases available
    /// - Throws: ReleazioError if configuration is missing or network request fails
    @available(*, deprecated, message: "Use checkUpdates() instead. This method doesn't provide update type and state information needed for proper update handling.")
    public func getLatestRelease() async throws -> Release? {
        guard configuration != nil else {
            throw ReleazioError.configurationMissing
        }

        return try await releaseService.getLatestRelease()
    }

    /// Get changelog for a specific release
    /// - Parameter releaseId: The ID of the release
    /// - Returns: Changelog object
    /// - Throws: ReleazioError if configuration is missing or network request fails
    public func getChangelog(for releaseId: String) async throws -> Changelog {
        guard configuration != nil else {
            throw ReleazioError.configurationMissing
        }

        return try await releaseService.getChangelog(
            releaseId: releaseId
        )
    }
    
    /// Check for updates and return update state
    /// This is the main method for checking updates
    /// - Returns: UpdateState with all information about whether to show badges, popups, buttons
    /// - Throws: ReleazioError if configuration is missing or network request fails
    public func checkUpdates() async throws -> UpdateState {
        guard let configuration = configuration else {
            throw ReleazioError.configurationMissing
        }
        
        // Get config from API
        let config = try await releaseService.getConfig()
        
        // Get first channel data (typically there's one channel per platform)
        guard let channelData = config.data.first else {
            throw ReleazioError.apiError(code: "NO_CHANNEL_DATA", message: "No channel data found in config")
        }
        
        // Get current app version code from bundle
        // For iOS, app_version_code from API is compared with CFBundleVersion (build number)
        let currentVersionCode = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        
        if configuration.debugLoggingEnabled {
            print("📱 Current version code from bundle: \(currentVersionCode)")
            print("📱 Latest version code from API: \(channelData.appVersionCode)")
            print("📱 Version name from API: \(channelData.appVersionName)")
        }
        
        // Calculate update state using UpdateStateManager
        let updateState = updateStateManager.calculateUpdateState(
            channelData: channelData,
            currentVersionCode: currentVersionCode
        )
        
        // Track analytics
        analyticsService.trackEvent(.updateChecked(
            hasUpdate: updateState.isUpdateAvailable,
            currentVersion: updateState.currentVersion,
            latestVersion: updateState.latestVersion
        ))
        
        return updateState
    }
    
    /// Mark post as opened (for type 0 badge logic)
    /// - Parameter postURL: Post URL that was opened
    public func markPostAsOpened(postURL: String) {
        updateStateManager.markPostAsOpened(postURL: postURL)
    }
    
    /// Check if post was opened
    /// - Parameter postURL: Post URL to check
    /// - Returns: True if post was opened
    public func isPostOpened(postURL: String) -> Bool {
        return updateStateManager.isPostOpened(postURL: postURL)
    }
    
    /// Mark popup as shown (for types 2, 3)
    /// - Parameters:
    ///   - version: Version identifier
    ///   - updateType: Update type
    public func markPopupAsShown(version: String, updateType: Int) {
        updateStateManager.markPopupAsShown(version: version, updateType: updateType)
    }
    
    /// Skip update (for type 3)
    /// - Parameter version: Version identifier
    /// - Returns: Remaining skip attempts
    public func skipUpdate(version: String) -> Int {
        return updateStateManager.skipUpdate(version: version)
    }
    
    /// Open App Store for update
    /// Opens the update URL from UpdateState (app_url or app_deeplink)
    /// - Parameter updateState: Update state containing update URL
    /// - Returns: True if URL was opened successfully, false otherwise
    @discardableResult
    public func openAppStore(updateState: UpdateState) -> Bool {
        guard let urlString = updateState.updateURL,
              let url = URL(string: urlString) else {
            if let configuration = configuration, configuration.debugLoggingEnabled {
                print("⚠️ No update URL found in update state")
            }
            return false
        }
        
        #if canImport(UIKit)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: { success in
                if let configuration = self.configuration, configuration.debugLoggingEnabled {
                    print(success ? "✅ Opened App Store URL: \(urlString)" : "❌ Failed to open App Store URL: \(urlString)")
                }
            })
            return true
        } else {
            if let configuration = configuration, configuration.debugLoggingEnabled {
                print("❌ Cannot open URL: \(urlString)")
            }
            return false
        }
        #elseif os(macOS)
        // For macOS, use NSWorkspace
        NSWorkspace.shared.open(url)
        return true
        #else
        return false
        #endif
    }
    
    /// Open post URL (for badge click or info button)
    /// Opens the post URL from UpdateState (post_url or posts_url)
    /// - Parameter updateState: Update state containing badge URL
    /// - Returns: True if URL was opened successfully, false otherwise
    @discardableResult
    public func openPostURL(updateState: UpdateState) -> Bool {
        guard let urlString = updateState.badgeURL,
              let url = URL(string: urlString) else {
            if let configuration = configuration, configuration.debugLoggingEnabled {
                print("⚠️ No post URL found in update state")
            }
            return false
        }
        
        #if canImport(UIKit)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: { success in
                if let configuration = self.configuration, configuration.debugLoggingEnabled {
                    print(success ? "✅ Opened post URL: \(urlString)" : "❌ Failed to open post URL: \(urlString)")
                }
            })
            
            // Mark post as opened (for type 0 badge logic)
            if updateState.updateType == 0 {
                markPostAsOpened(postURL: urlString)
            }
            
            return true
        } else {
            if let configuration = configuration, configuration.debugLoggingEnabled {
                print("❌ Cannot open URL: \(urlString)")
            }
            return false
        }
        #elseif os(macOS)
        // For macOS, use NSWorkspace
        NSWorkspace.shared.open(url)
        if updateState.updateType == 0 {
            markPostAsOpened(postURL: urlString)
        }
        return true
        #else
        return false
        #endif
    }

    /// Show update prompt UI (requires window/scene context)
    @available(*, deprecated, message: "This method is not implemented. Use ReleazioUpdatePromptView (SwiftUI) or ReleazioUpdatePromptViewController (UIKit) directly to show update prompts.")
    public func showUpdatePrompt() {
        // Implementation will depend on UI framework and context
        // This will be implemented in UI module
        analyticsService.trackEvent(.updatePromptShown)
    }

    /// Get current configuration
    /// - Returns: Current configuration or nil if not configured
    public func getConfiguration() -> ReleazioConfiguration? {
        return configuration
    }

    /// Reset SDK configuration and clear cached data
    public func reset() {
        configuration = nil
        Task {
            await releaseService.clearCache()
            analyticsService.trackEvent(.sdkReset)
        }
    }

    // MARK: - Private Methods

    /// Setup services with current configuration
    private func setupServices() {
        guard let configuration = configuration else { return }

        releaseService.configure(with: configuration)
        analyticsService.configure(with: configuration)
    }
}

// MARK: - Bundle Extension

private extension Bundle {
    var versionString: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "0"
    }
}