//
//  UpdateStateManager.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation

/// Manager for determining update state and UI visibility
public class UpdateStateManager {
    
    // MARK: - Properties
    
    private let storage: UpdateStorage
    
    // MARK: - Initialization
    
    public init(storage: UpdateStorage = UpdateStorage()) {
        self.storage = storage
    }
    
    // MARK: - Public Methods
    
    /// Calculate update state from channel data
    /// - Parameters:
    ///   - channelData: Channel data from API
    ///   - currentVersionCode: Current app version code from bundle
    /// - Returns: UpdateState with all visibility flags
    public func calculateUpdateState(
        channelData: ChannelData,
        currentVersionCode: String
    ) -> UpdateState {
        // Compare versions (semantic comparison)
        let isUpdateAvailable = compareVersions(
            current: currentVersionCode,
            latest: channelData.appVersionCode
        )
        
        // Determine badge visibility (for type 0)
        let shouldShowBadge = shouldShowBadgeForType0(
            channelData: channelData,
            isUpdateAvailable: isUpdateAvailable
        )
        
        // Determine popup visibility (for types 2, 3)
        let shouldShowPopup = shouldShowPopupForTypes2and3(
            channelData: channelData,
            isUpdateAvailable: isUpdateAvailable
        )
        
        // Determine update button visibility (for type 1)
        let shouldShowUpdateButton = shouldShowUpdateButtonForType1(
            channelData: channelData,
            isUpdateAvailable: isUpdateAvailable
        )
        
        // Get remaining skip attempts (for type 3)
        let remainingSkipAttempts = getRemainingSkipAttempts(
            channelData: channelData
        )
        
        // Determine badge URL (post_url if not opened, posts_url if opened)
        let badgeURL = getBadgeURL(channelData: channelData)
        
        // Get version names for display
        let currentVersionName = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? currentVersionCode
        
        return UpdateState(
            updateType: channelData.updateType,
            shouldShowBadge: shouldShowBadge,
            shouldShowPopup: shouldShowPopup,
            shouldShowUpdateButton: shouldShowUpdateButton,
            remainingSkipAttempts: remainingSkipAttempts,
            channelData: channelData,
            badgeURL: badgeURL,
            updateURL: channelData.appUrl ?? channelData.appDeeplink,
            currentVersion: currentVersionCode,
            latestVersion: channelData.appVersionCode,
            currentVersionName: currentVersionName,
            latestVersionName: channelData.appVersionName,
            isUpdateAvailable: isUpdateAvailable
        )
    }
    
    /// Mark post as opened (for type 0 badge logic)
    /// - Parameter postURL: Post URL to mark as opened
    public func markPostAsOpened(postURL: String) {
        storage.markPostAsOpened(postURL)
    }
    
    /// Mark popup as shown (for type 2, 3)
    /// - Parameters:
    ///   - version: Version identifier
    ///   - updateType: Update type
    public func markPopupAsShown(version: String, updateType: Int) {
        storage.setLastPopupShownTime(Date(), for: version)
        storage.setLastPopupVersion(version)
    }
    
    /// Decrement skip attempts (for type 3)
    /// - Parameter version: Version identifier
    /// - Returns: New remaining count
    public func skipUpdate(version: String) -> Int {
        return storage.decrementSkipAttempts(for: version)
    }
    
    /// Initialize skip attempts from API (for type 3)
    /// - Parameters:
    ///   - skipAttempts: Skip attempts from API
    ///   - version: Version identifier
    public func initializeSkipAttempts(_ skipAttempts: Int, for version: String) {
        storage.initializeSkipAttempts(skipAttempts, for: version)
    }
    
    // MARK: - Private Methods
    
    private func compareVersions(current: String, latest: String) -> Bool {
        // Try semantic version comparison first
        if let currentVersion = try? AppVersion(versionString: current),
           let latestVersion = try? AppVersion(versionString: latest) {
            return latestVersion > currentVersion
        }
        
        // Fallback to string comparison
        return latest.compare(current, options: .numeric) == .orderedDescending
    }
    
    private func shouldShowBadgeForType0(
        channelData: ChannelData,
        isUpdateAvailable: Bool
    ) -> Bool {
        // Badge only for type 0 (latest)
        guard channelData.updateType == 0 else {
            return false
        }
        
        // Only show if update is available
        guard isUpdateAvailable else {
            return false
        }
        
        // Check if post was already opened
        if let postURL = channelData.postUrl {
            return !storage.isPostOpened(postURL)
        }
        
        return false
    }
    
    private func shouldShowPopupForTypes2and3(
        channelData: ChannelData,
        isUpdateAvailable: Bool
    ) -> Bool {
        // Popup only for types 2 and 3
        guard channelData.updateType == 2 || channelData.updateType == 3 else {
            return false
        }
        
        // Only show if update is available
        guard isUpdateAvailable else {
            return false
        }
        
        let version = channelData.appVersionCode
        
        // For type 2: check show_interval
        if channelData.updateType == 2 {
            return storage.shouldShowPopup(
                interval: channelData.showInterval,
                for: version
            )
        }
        
        // For type 3: always show (but check skip attempts)
        if channelData.updateType == 3 {
            // Initialize skip attempts if not set
            let remaining = storage.getRemainingSkipAttempts(for: version)
            if remaining == 0 {
                // Check if this is first time by trying to get a default value
                // If we get 0 and userDefaults doesn't have the key, initialize
                let key = "releazio_skip_attempts_remaining_\(version)"
                if userDefaults.object(forKey: key) == nil {
                    storage.initializeSkipAttempts(channelData.skipAttempts, for: version)
                }
            }
            return true
        }
        
        return false
    }
    
    private func shouldShowUpdateButtonForType1(
        channelData: ChannelData,
        isUpdateAvailable: Bool
    ) -> Bool {
        // Update button only for type 1 (silent)
        guard channelData.updateType == 1 else {
            return false
        }
        
        return isUpdateAvailable
    }
    
    private func getRemainingSkipAttempts(channelData: ChannelData) -> Int {
        guard channelData.updateType == 3 else {
            return 0
        }
        
        let version = channelData.appVersionCode
        return storage.getRemainingSkipAttempts(for: version)
    }
    
    private func getBadgeURL(channelData: ChannelData) -> String? {
        guard channelData.updateType == 0 else {
            return nil
        }
        
        guard let postURL = channelData.postUrl else {
            return channelData.postsUrl
        }
        
        // If post was opened, return posts_url, otherwise post_url
        if storage.isPostOpened(postURL) {
            return channelData.postsUrl
        }
        
        return postURL
    }
    
    // MARK: - Helper
    
    private var userDefaults: UserDefaults {
        return UserDefaults.standard
    }
}

