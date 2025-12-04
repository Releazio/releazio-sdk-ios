//
//  UpdatePromptTheme.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Update prompt style
public enum UpdatePromptStyle {
    case inAppUpdate
    case native
    
    /// Default style
    public static let `default`: UpdatePromptStyle = .native
}

/// Theme configuration for update prompt
public struct UpdatePromptTheme {
    
    // MARK: - Style
    
    public let style: UpdatePromptStyle
    
    // MARK: - Colors (Light/Dark aware)
    
    /// Background color
    public var backgroundColor: Color {
        .white
    }
    
    /// Header background color (for InAppUpdate style)
    public var headerBackgroundColor: Color {
        switch style {
        case .inAppUpdate:
            return Color(red: 0.84, green: 0.16, blue: 0.18) // InAppUpdate red
        case .native:
            return colorScheme == .dark ? Color(white: 0.0) : Color(white: 1.0)
        }
    }
    
    /// Header text color
    public var headerTextColor: Color {
        switch style {
        case .inAppUpdate:
            return .white
        case .native:
            return .primary
        }
    }
    
    /// Primary button color
    public var primaryButtonColor: Color {
        switch style {
        case .inAppUpdate:
            return .black
        case .native:
            return .black
        }
    }
    
    /// Primary button text color
    public var primaryButtonTextColor: Color {
        switch style {
        case .inAppUpdate:
            return .white
        case .native:
            return .white
        }
    }
    
    /// Link color (for "Что нового")
    public var linkColor: Color {
        switch colorScheme {
        case .dark:
            return Color(red: 0.3, green: 0.5, blue: 1.0)
        default:
            return .blue
        }
    }
    
    /// Text color
    public var textColor: Color {
        .black
    }
    
    /// Secondary text color
    public var secondaryTextColor: Color {
        switch colorScheme {
        case .dark:
            return Color(white: 0.7)
        default:
            return .secondary
        }
    }
    
    /// Overlay color
    public var overlayColor: Color {
        switch colorScheme {
        case .dark:
            return Color.black.opacity(0.6)
        default:
            return Color.black.opacity(0.4)
        }
    }
    
    /// Close button color
    public var closeButtonColor: Color {
        return .gray
    }
    
    // MARK: - Properties
    
    public let colorScheme: ColorScheme
    
    // MARK: - Initialization
    
    /// Initialize theme
    /// - Parameters:
    ///   - style: Update prompt style (InAppUpdate or Native)
    ///   - colorScheme: Color scheme (light or dark)
    public init(style: UpdatePromptStyle = .default, colorScheme: ColorScheme = .light) {
        self.style = style
        self.colorScheme = colorScheme
    }
    
    // MARK: - Factory Methods
    
    /// InAppUpdate light theme
    public static var inAppUpdateLight: UpdatePromptTheme {
        return UpdatePromptTheme(style: .inAppUpdate, colorScheme: .light)
    }
    
    /// InAppUpdate dark theme
    public static var inAppUpdateDark: UpdatePromptTheme {
        return UpdatePromptTheme(style: .inAppUpdate, colorScheme: .dark)
    }
    
    /// Native light theme
    public static var nativeLight: UpdatePromptTheme {
        return UpdatePromptTheme(style: .native, colorScheme: .light)
    }
    
    /// Native dark theme
    public static var nativeDark: UpdatePromptTheme {
        return UpdatePromptTheme(style: .native, colorScheme: .dark)
    }
}

#if canImport(UIKit) && !os(macOS)

/// UIKit theme for update prompt
public struct UpdatePromptUIKitTheme {
    
    public let style: UpdatePromptStyle
    
    public var backgroundColor: UIColor {
        switch (style, colorScheme) {
        case (.inAppUpdate, .dark):
            return UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        case (.inAppUpdate, _):
            return .white
        case (.native, _):
            return .systemBackground
        }
    }
    
    public var headerBackgroundColor: UIColor {
        switch style {
        case .inAppUpdate:
            return UIColor(red: 0.84, green: 0.16, blue: 0.18, alpha: 1.0) // InAppUpdate red
        case .native:
            return .systemBackground
        }
    }
    
    public var headerTextColor: UIColor {
        switch style {
        case .inAppUpdate:
            return .white
        case .native:
            return .label
        }
    }
    
    public var primaryButtonColor: UIColor {
        switch style {
        case .inAppUpdate:
            return UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // InAppUpdate yellow
        case .native:
            return .systemBlue
        }
    }
    
    public var primaryButtonTextColor: UIColor {
        switch style {
        case .inAppUpdate:
            return .black
        case .native:
            return .white
        }
    }
    
    public var linkColor: UIColor {
        switch colorScheme {
        case .dark:
            return UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0)
        default:
            return .systemBlue
        }
    }
    
    public var textColor: UIColor {
        switch colorScheme {
        case .dark:
            return .white
        default:
            return .black
        }
    }
    
    public var secondaryTextColor: UIColor {
        switch colorScheme {
        case .dark:
            return UIColor(white: 0.7, alpha: 1.0)
        default:
            return .secondaryLabel
        }
    }
    
    public var overlayColor: UIColor {
        switch colorScheme {
        case .dark:
            return UIColor.black.withAlphaComponent(0.6)
        default:
            return UIColor.black.withAlphaComponent(0.4)
        }
    }
    
    public var closeButtonColor: UIColor {
        switch (style, colorScheme) {
        case (.inAppUpdate, _):
            return .white
        case (.native, .dark):
            return .white
        case (.native, _):
            return .gray
        }
    }
    
    public let colorScheme: UIUserInterfaceStyle
    
    public init(style: UpdatePromptStyle = .default, colorScheme: UIUserInterfaceStyle = .light) {
        self.style = style
        self.colorScheme = colorScheme
    }
    
    public static var inAppUpdateLight: UpdatePromptUIKitTheme {
        return UpdatePromptUIKitTheme(style: .inAppUpdate, colorScheme: .light)
    }
    
    public static var inAppUpdateDark: UpdatePromptUIKitTheme {
        return UpdatePromptUIKitTheme(style: .inAppUpdate, colorScheme: .dark)
    }
    
    public static var nativeLight: UpdatePromptUIKitTheme {
        return UpdatePromptUIKitTheme(style: .native, colorScheme: .light)
    }
    
    public static var nativeDark: UpdatePromptUIKitTheme {
        return UpdatePromptUIKitTheme(style: .native, colorScheme: .dark)
    }
}

#endif

