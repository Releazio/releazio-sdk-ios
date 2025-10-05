//
//  UpdateState.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation

/// State returned by checkUpdates() method
public struct UpdateState {
    
    /// Update type from API (0, 1, 2, 3)
    public let updateType: Int
    
    /// Whether badge should be shown (for type 0)
    public let shouldShowBadge: Bool
    
    /// Whether popup should be shown (for types 2, 3)
    public let shouldShowPopup: Bool
    
    /// Whether update button should be shown (for type 1)
    public let shouldShowUpdateButton: Bool
    
    /// Remaining skip attempts (for type 3)
    public let remainingSkipAttempts: Int
    
    /// Full channel data from API
    public let channelData: ChannelData
    
    /// URL to open when badge is clicked (post_url or posts_url)
    public let badgeURL: String?
    
    /// URL for app update (app_url)
    public let updateURL: String?
    
    /// Current app version code (for comparison)
    public let currentVersion: String
    
    /// Latest available version code from API (for comparison)
    public let latestVersion: String
    
    /// Current app version name (for display, e.g., "1.2.3")
    public let currentVersionName: String
    
    /// Latest available version name from API (for display, e.g., "2.5.1")
    public let latestVersionName: String
    
    /// Whether update is available (version comparison)
    public let isUpdateAvailable: Bool
    
    // MARK: - Initialization
    
    public init(
        updateType: Int,
        shouldShowBadge: Bool,
        shouldShowPopup: Bool,
        shouldShowUpdateButton: Bool,
        remainingSkipAttempts: Int,
        channelData: ChannelData,
        badgeURL: String?,
        updateURL: String?,
        currentVersion: String,
        latestVersion: String,
        currentVersionName: String,
        latestVersionName: String,
        isUpdateAvailable: Bool
    ) {
        self.updateType = updateType
        self.shouldShowBadge = shouldShowBadge
        self.shouldShowPopup = shouldShowPopup
        self.shouldShowUpdateButton = shouldShowUpdateButton
        self.remainingSkipAttempts = remainingSkipAttempts
        self.channelData = channelData
        self.badgeURL = badgeURL
        self.updateURL = updateURL
        self.currentVersion = currentVersion
        self.latestVersion = latestVersion
        self.currentVersionName = currentVersionName
        self.latestVersionName = latestVersionName
        self.isUpdateAvailable = isUpdateAvailable
    }
}

