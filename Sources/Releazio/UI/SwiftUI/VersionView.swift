//
//  VersionView.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import SwiftUI

/// SwiftUI view for displaying app version with update button
/// Displays version string and optional update button if update is available
public struct VersionView: View {
    
    // MARK: - Properties
    
    /// Current version string
    public let version: String
    
    /// Whether update is available
    public let isUpdateAvailable: Bool
    
    /// Update button action
    public let onUpdateTap: (() -> Void)?
    
    /// Custom colors for component
    private let customColors: UIComponentColors?
    
    /// Custom localization strings
    private let customStrings: UILocalizationStrings?
    
    /// Localization manager (with auto-detected locale)
    private let localization: LocalizationManager
    
    /// Color scheme
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Initialization
    
    /// Initialize version view with UpdateState
    /// - Parameters:
    ///   - updateState: Update state from checkUpdates()
    ///   - customColors: Custom colors for buttons and text (optional)
    ///   - customStrings: Custom localization strings (optional)
    ///   - onUpdateTap: Action when update button is tapped
    public init(
        updateState: UpdateState,
        customColors: UIComponentColors? = nil,
        customStrings: UILocalizationStrings? = nil,
        onUpdateTap: (() -> Void)? = nil
    ) {
        // Use version name for display (e.g., "1.2.3" instead of build number)
        self.version = updateState.currentVersionName
        // Show update button if update is available (for all types, not just type 1)
        // This is for the bottom component which should show update button whenever there's an update
        self.isUpdateAvailable = updateState.isUpdateAvailable
        self.customColors = customColors
        self.customStrings = customStrings
        // Auto-detect locale from system
        let detectedLocale = LocalizationManager.detectSystemLocale()
        self.localization = LocalizationManager(locale: detectedLocale)
        self.onUpdateTap = onUpdateTap
    }
    
    /// Initialize version view
    /// - Parameters:
    ///   - version: Current app version string
    ///   - isUpdateAvailable: Whether update is available
    ///   - customColors: Custom colors for buttons and text (optional)
    ///   - customStrings: Custom localization strings (optional)
    ///   - onUpdateTap: Action when update button is tapped
    public init(
        version: String,
        isUpdateAvailable: Bool = false,
        customColors: UIComponentColors? = nil,
        customStrings: UILocalizationStrings? = nil,
        onUpdateTap: (() -> Void)? = nil
    ) {
        self.version = version
        self.isUpdateAvailable = isUpdateAvailable
        self.customColors = customColors
        self.customStrings = customStrings
        // Auto-detect locale from system
        let detectedLocale = LocalizationManager.detectSystemLocale()
        self.localization = LocalizationManager(locale: detectedLocale)
        self.onUpdateTap = onUpdateTap
    }
    
    // MARK: - Body
    
    public var body: some View {
        HStack(spacing: 12) {
            // Version label
            Text(localizedVersionText)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(versionBackgroundColor)
                .cornerRadius(10)
            
            // Update button (if available)
            if isUpdateAvailable {
                Button(action: {
                    onUpdateTap?()
                }) {
                    Text(updateButtonText)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(updateButtonTextColor)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(updateButtonColor)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var localizedVersionText: String {
        // Format: "Version {version}" or "Версия {version}"
        let versionLabelText = customStrings?.versionText ?? localization.versionText
        return "\(versionLabelText) \(version)"
    }
    
    private var versionBackgroundColor: Color {
        if let customColor = customColors?.versionBackgroundColor {
            return Color(customColor)
        }
        switch colorScheme {
        case .dark:
            return Color(white: 0.2)
        default:
            return Color(white: 0.95)
        }
    }
    
    private var textColor: Color {
        if let customColor = customColors?.versionTextColor {
            return Color(customColor)
        }
        switch colorScheme {
        case .dark:
            return .white
        default:
            return .black
        }
    }
    
    private var updateButtonColor: Color {
        if let customColor = customColors?.updateButtonColor {
            return Color(customColor)
        }
        // Default Olimp yellow
        return Color(red: 1.0, green: 0.84, blue: 0.0)
    }
    
    private var updateButtonTextColor: Color {
        if let customColor = customColors?.updateButtonTextColor {
            return Color(customColor)
        }
        // Default black text on yellow button
        return .black
    }
    
    private var updateButtonText: String {
        return customStrings?.updateButtonText ?? localization.updateButtonText
    }
}

