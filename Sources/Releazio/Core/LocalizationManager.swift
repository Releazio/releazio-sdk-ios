//
//  LocalizationManager.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation

/// Manager for handling SDK localization
public class LocalizationManager {
    
    // MARK: - Properties
    
    private let bundle: Bundle
    
    /// Current locale identifier
    public let locale: String
    
    // MARK: - Initialization
    
    /// Initialize localization manager
    /// - Parameters:
    ///   - locale: Locale identifier (e.g., "en", "ru")
    ///   - bundle: Bundle for resources (default: main bundle)
    public init(locale: String = "en", bundle: Bundle = Bundle.main) {
        self.locale = locale
        self.bundle = bundle
    }
    
    // MARK: - Localization
    
    /// Get localized string for key
    /// - Parameter key: Localization key
    /// - Returns: Localized string or key if not found
    public func localizedString(for key: String) -> String {
        // Try to load localization from SDK bundle
        guard let sdkBundle = Bundle(identifier: "com.releazio.Releazio") ?? findSDKBundle() else {
            // Fallback to hardcoded strings
            return fallbackString(for: key)
        }
        
        let bundlePath = sdkBundle.path(forResource: locale, ofType: "lproj")
        let localizationBundle = bundlePath.flatMap { Bundle(path: $0) } ?? sdkBundle
        
        let localized = localizationBundle.localizedString(forKey: key, value: key, table: nil)
        
        // If localization not found, return fallback
        if localized == key {
            return fallbackString(for: key)
        }
        
        return localized
    }
    
    // MARK: - Private Methods
    
    private func findSDKBundle() -> Bundle? {
        // Try to find SDK bundle by class name
        let className = String(describing: LocalizationManager.self)
        guard let path = Bundle.main.path(forResource: className, ofType: nil) else {
            // Try to find Releazio bundle
            if let url = Bundle.main.url(forResource: "Releazio", withExtension: "bundle") {
                return Bundle(url: url)
            }
            return nil
        }
        return Bundle(path: path)
    }
    
    private func fallbackString(for key: String) -> String {
        // Fallback strings in both languages
        let fallbacks: [String: [String: String]] = [
            "en": [
                "update.title": "Update Available",
                "update.message": "A new version of the app is available. Please update to continue.",
                "update.button.update": "Update",
                "update.button.skip": "Skip",
                "update.button.close": "Close",
                "update.badge.new": "New",
                "update.whats.new": "What's New",
                "update.skip.remaining": "Skip attempts remaining: %d"
            ],
            "ru": [
                "update.title": "Доступно обновление",
                "update.message": "Доступна новая версия приложения. Обновите приложение, чтобы продолжить.",
                "update.button.update": "Обновить",
                "update.button.skip": "Пропустить",
                "update.button.close": "Закрыть",
                "update.badge.new": "Новое",
                "update.whats.new": "Что нового",
                "update.skip.remaining": "Осталось пропусков: %d"
            ]
        ]
        
        let strings = fallbacks[locale] ?? fallbacks["en"]!
        return strings[key] ?? key
    }
    
    /// Get localized string with format arguments
    /// - Parameters:
    ///   - key: Localization key
    ///   - arguments: Format arguments
    /// - Returns: Formatted localized string
    public func localizedString(for key: String, arguments: CVarArg...) -> String {
        let template = localizedString(for: key)
        return String(format: template, arguments: arguments)
    }
}

// MARK: - Static Methods

extension LocalizationManager {
    
    /// Automatically detect system locale and return supported locale identifier
    /// - Returns: "ru" if system language is Russian, otherwise "en"
    public static func detectSystemLocale() -> String {
        let languageCode = Locale.current.languageCode ?? "en"
        // Поддерживаем только "en" и "ru", для остальных fallback на "en"
        return (languageCode == "ru") ? "ru" : "en"
    }
}

// MARK: - Extension for convenient access

extension LocalizationManager {
    
    /// Update title
    public var updateTitle: String {
        return localizedString(for: "update.title")
    }
    
    /// Update message
    public var updateMessage: String {
        return localizedString(for: "update.message")
    }
    
    /// Update button text
    public var updateButtonText: String {
        return localizedString(for: "update.button.update")
    }
    
    /// Skip button text
    public var skipButtonText: String {
        return localizedString(for: "update.button.skip")
    }
    
    /// Close button text
    public var closeButtonText: String {
        return localizedString(for: "update.button.close")
    }
    
    /// Badge new text
    public var badgeNewText: String {
        return localizedString(for: "update.badge.new")
    }
    
    /// What's new text
    public var whatsNewText: String {
        return localizedString(for: "update.whats.new")
    }
    
    /// Version text (localized)
    public var versionText: String {
        return locale == "ru" ? "Версия" : "Version"
    }
    
    /// Skip attempts remaining text
    /// - Parameter count: Remaining count
    /// - Returns: Formatted string
    public func skipRemainingText(count: Int) -> String {
        return localizedString(for: "update.skip.remaining", arguments: count)
    }
}

