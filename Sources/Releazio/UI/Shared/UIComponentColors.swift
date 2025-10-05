//
//  UIComponentColors.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Custom colors for UI components customization
/// All colors are optional - if nil, default colors will be used
#if canImport(UIKit)
public struct UIComponentColors {
    /// Update button background color
    public let updateButtonColor: UIColor?
    
    /// Update button text color
    public let updateButtonTextColor: UIColor?
    
    /// Skip button background color
    public let skipButtonColor: UIColor?
    
    /// Skip button text color
    public let skipButtonTextColor: UIColor?
    
    /// Close button color (icon/text)
    public let closeButtonColor: UIColor?
    
    /// Link color (for "What's New" links)
    public let linkColor: UIColor?
    
    /// Badge background color
    public let badgeColor: UIColor?
    
    /// Badge text color
    public let badgeTextColor: UIColor?
    
    /// Version label background color
    public let versionBackgroundColor: UIColor?
    
    /// Version label text color
    public let versionTextColor: UIColor?
    
    /// Primary text color (for titles, messages)
    public let primaryTextColor: UIColor?
    
    /// Secondary text color (for subtitles, descriptions)
    public let secondaryTextColor: UIColor?
    
    // MARK: - Initialization
    
    public init(
        updateButtonColor: UIColor? = nil,
        updateButtonTextColor: UIColor? = nil,
        skipButtonColor: UIColor? = nil,
        skipButtonTextColor: UIColor? = nil,
        closeButtonColor: UIColor? = nil,
        linkColor: UIColor? = nil,
        badgeColor: UIColor? = nil,
        badgeTextColor: UIColor? = nil,
        versionBackgroundColor: UIColor? = nil,
        versionTextColor: UIColor? = nil,
        primaryTextColor: UIColor? = nil,
        secondaryTextColor: UIColor? = nil
    ) {
        self.updateButtonColor = updateButtonColor
        self.updateButtonTextColor = updateButtonTextColor
        self.skipButtonColor = skipButtonColor
        self.skipButtonTextColor = skipButtonTextColor
        self.closeButtonColor = closeButtonColor
        self.linkColor = linkColor
        self.badgeColor = badgeColor
        self.badgeTextColor = badgeTextColor
        self.versionBackgroundColor = versionBackgroundColor
        self.versionTextColor = versionTextColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
    }
}
#else
public struct UIComponentColors {
    /// Update button background color
    public let updateButtonColor: Color?
    
    /// Update button text color
    public let updateButtonTextColor: Color?
    
    /// Skip button background color
    public let skipButtonColor: Color?
    
    /// Skip button text color
    public let skipButtonTextColor: Color?
    
    /// Close button color (icon/text)
    public let closeButtonColor: Color?
    
    /// Link color (for "What's New" links)
    public let linkColor: Color?
    
    /// Badge background color
    public let badgeColor: Color?
    
    /// Badge text color
    public let badgeTextColor: Color?
    
    /// Version label background color
    public let versionBackgroundColor: Color?
    
    /// Version label text color
    public let versionTextColor: Color?
    
    /// Primary text color (for titles, messages)
    public let primaryTextColor: Color?
    
    /// Secondary text color (for subtitles, descriptions)
    public let secondaryTextColor: Color?
    
    // MARK: - Initialization
    
    public init(
        updateButtonColor: Color? = nil,
        updateButtonTextColor: Color? = nil,
        skipButtonColor: Color? = nil,
        skipButtonTextColor: Color? = nil,
        closeButtonColor: Color? = nil,
        linkColor: Color? = nil,
        badgeColor: Color? = nil,
        badgeTextColor: Color? = nil,
        versionBackgroundColor: Color? = nil,
        versionTextColor: Color? = nil,
        primaryTextColor: Color? = nil,
        secondaryTextColor: Color? = nil
    ) {
        self.updateButtonColor = updateButtonColor
        self.updateButtonTextColor = updateButtonTextColor
        self.skipButtonColor = skipButtonColor
        self.skipButtonTextColor = skipButtonTextColor
        self.closeButtonColor = closeButtonColor
        self.linkColor = linkColor
        self.badgeColor = badgeColor
        self.badgeTextColor = badgeTextColor
        self.versionBackgroundColor = versionBackgroundColor
        self.versionTextColor = versionTextColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
    }
}
#endif


