//
//  UILocalizationStrings.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation

/// Custom localization strings for UI components
/// All strings are optional - if nil, default localized strings from SDK will be used
/// This allows integrators to provide their own translations or override specific strings
public struct UILocalizationStrings {
    
    /// Update prompt title (e.g., "Update Available")
    public let updateTitle: String?
    
    /// Update prompt message (e.g., "A new version is available...")
    public let updateMessage: String?
    
    /// Update button text (e.g., "Update")
    public let updateButtonText: String?
    
    /// Skip button text (e.g., "Skip")
    public let skipButtonText: String?
    
    /// Close button text (e.g., "Close")
    public let closeButtonText: String?
    
    /// Badge "New" text
    public let badgeNewText: String?
    
    /// "What's New" link text
    public let whatsNewText: String?
    
    /// Version label text (e.g., "Version" or "Версия")
    public let versionText: String?
    
    /// Skip attempts remaining text format (e.g., "Skip attempts remaining: %d" or "Осталось пропусков: %d")
    /// Use "%d" placeholder for the number
    public let skipRemainingTextFormat: String?
    
    // MARK: - Initialization
    
    /// Initialize with custom localization strings
    /// - Parameters:
    ///   - updateTitle: Update prompt title
    ///   - updateMessage: Update prompt message
    ///   - updateButtonText: Update button text
    ///   - skipButtonText: Skip button text
    ///   - closeButtonText: Close button text
    ///   - badgeNewText: Badge "New" text
    ///   - whatsNewText: "What's New" link text
    ///   - versionText: Version label text
    ///   - skipRemainingTextFormat: Skip attempts format string with %d placeholder
    public init(
        updateTitle: String? = nil,
        updateMessage: String? = nil,
        updateButtonText: String? = nil,
        skipButtonText: String? = nil,
        closeButtonText: String? = nil,
        badgeNewText: String? = nil,
        whatsNewText: String? = nil,
        versionText: String? = nil,
        skipRemainingTextFormat: String? = nil
    ) {
        self.updateTitle = updateTitle
        self.updateMessage = updateMessage
        self.updateButtonText = updateButtonText
        self.skipButtonText = skipButtonText
        self.closeButtonText = closeButtonText
        self.badgeNewText = badgeNewText
        self.whatsNewText = whatsNewText
        self.versionText = versionText
        self.skipRemainingTextFormat = skipRemainingTextFormat
    }
}


