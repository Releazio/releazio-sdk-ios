//
//  UpdateStorage.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation

/// Service for storing update-related data locally
public class UpdateStorage {
    
    // MARK: - Keys
    
    private enum Keys {
        static let skipAttemptsRemaining = "releazio_skip_attempts_remaining"
        static let lastPopupShownTime = "releazio_last_popup_shown_time"
        static let lastPopupVersion = "releazio_last_popup_version"
        static let postOpenedIds = "releazio_post_opened_ids"
        static let currentVersion = "releazio_current_version"
    }
    
    // MARK: - Properties
    
    private let userDefaults: UserDefaults
    
    // MARK: - Initialization
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Skip Attempts
    
    /// Get remaining skip attempts for current version
    /// - Parameter version: Version identifier
    /// - Returns: Remaining skip attempts
    public func getRemainingSkipAttempts(for version: String) -> Int {
        let key = "\(Keys.skipAttemptsRemaining)_\(version)"
        return userDefaults.integer(forKey: key)
    }
    
    /// Set remaining skip attempts for current version
    /// - Parameters:
    ///   - attempts: Number of remaining attempts
    ///   - version: Version identifier
    public func setRemainingSkipAttempts(_ attempts: Int, for version: String) {
        let key = "\(Keys.skipAttemptsRemaining)_\(version)"
        userDefaults.set(attempts, forKey: key)
    }
    
    /// Decrement skip attempts for current version
    /// - Parameter version: Version identifier
    /// - Returns: New remaining count
    public func decrementSkipAttempts(for version: String) -> Int {
        let current = getRemainingSkipAttempts(for: version)
        let newValue = max(0, current - 1)
        setRemainingSkipAttempts(newValue, for: version)
        return newValue
    }
    
    /// Initialize skip attempts from API value
    /// - Parameters:
    ///   - skipAttempts: Skip attempts from API
    ///   - version: Version identifier
    public func initializeSkipAttempts(_ skipAttempts: Int, for version: String) {
        // Only initialize if not already set for this version
        let key = "\(Keys.skipAttemptsRemaining)_\(version)"
        if userDefaults.object(forKey: key) == nil {
            setRemainingSkipAttempts(skipAttempts, for: version)
        }
    }
    
    // MARK: - Show Interval
    
    /// Get last popup shown time
    /// - Parameter version: Version identifier
    /// - Returns: Date of last popup shown or nil
    public func getLastPopupShownTime(for version: String) -> Date? {
        let key = "\(Keys.lastPopupShownTime)_\(version)"
        return userDefaults.object(forKey: key) as? Date
    }
    
    /// Set last popup shown time
    /// - Parameters:
    ///   - date: Date of popup shown
    ///   - version: Version identifier
    public func setLastPopupShownTime(_ date: Date, for version: String) {
        let key = "\(Keys.lastPopupShownTime)_\(version)"
        userDefaults.set(date, forKey: key)
    }
    
    /// Check if enough time has passed since last popup shown
    /// - Parameters:
    ///   - interval: Show interval in minutes
    ///   - version: Version identifier
    /// - Returns: True if enough time has passed or never shown
    public func shouldShowPopup(interval: Int, for version: String) -> Bool {
        guard interval > 0 else {
            // If interval is 0, show every time
            return true
        }
        
        guard let lastShown = getLastPopupShownTime(for: version) else {
            // Never shown before
            return true
        }
        
        let minutesSinceLastShow = Date().timeIntervalSince(lastShown) / 60
        return Int(minutesSinceLastShow) >= interval
    }
    
    /// Get last popup version
    /// - Returns: Version string or nil
    public func getLastPopupVersion() -> String? {
        return userDefaults.string(forKey: Keys.lastPopupVersion)
    }
    
    /// Set last popup version
    /// - Parameter version: Version string
    public func setLastPopupVersion(_ version: String) {
        userDefaults.set(version, forKey: Keys.lastPopupVersion)
    }
    
    // MARK: - Post Opened Tracking
    
    /// Check if post was opened
    /// - Parameter postId: Post identifier (typically postUrl or version)
    /// - Returns: True if post was opened
    public func isPostOpened(_ postId: String) -> Bool {
        let openedIds = getOpenedPostIds()
        return openedIds.contains(postId)
    }
    
    /// Mark post as opened
    /// - Parameter postId: Post identifier
    public func markPostAsOpened(_ postId: String) {
        var openedIds = getOpenedPostIds()
        if !openedIds.contains(postId) {
            openedIds.append(postId)
            setOpenedPostIds(openedIds)
        }
    }
    
    /// Get all opened post IDs
    /// - Returns: Array of opened post IDs
    public func getOpenedPostIds() -> [String] {
        return userDefaults.stringArray(forKey: Keys.postOpenedIds) ?? []
    }
    
    /// Set opened post IDs
    /// - Parameter ids: Array of post IDs
    private func setOpenedPostIds(_ ids: [String]) {
        userDefaults.set(ids, forKey: Keys.postOpenedIds)
    }
    
    // MARK: - Current Version
    
    /// Get stored current version
    /// - Returns: Version string or nil
    public func getCurrentVersion() -> String? {
        return userDefaults.string(forKey: Keys.currentVersion)
    }
    
    /// Set current version
    /// - Parameter version: Version string
    public func setCurrentVersion(_ version: String) {
        userDefaults.set(version, forKey: Keys.currentVersion)
    }
    
    /// Check if version has changed since last check
    /// - Parameter version: Current version to check
    /// - Returns: True if version changed or never set
    public func hasVersionChanged(_ version: String) -> Bool {
        guard let storedVersion = getCurrentVersion() else {
            return true // Never set before
        }
        return storedVersion != version
    }
    
    // MARK: - Clear Data
    
    /// Clear all update-related data
    public func clearAll() {
        // Clear skip attempts for all versions (we don't know all keys, so we'll handle per version)
        // For now, clear specific keys
        
        // Clear all keys with our prefix
        let allKeys = userDefaults.dictionaryRepresentation().keys
        for key in allKeys {
            if key.hasPrefix("releazio_") {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
    
    /// Clear data for specific version
    /// - Parameter version: Version to clear data for
    public func clearData(for version: String) {
        let skipKey = "\(Keys.skipAttemptsRemaining)_\(version)"
        let timeKey = "\(Keys.lastPopupShownTime)_\(version)"
        userDefaults.removeObject(forKey: skipKey)
        userDefaults.removeObject(forKey: timeKey)
    }
}

