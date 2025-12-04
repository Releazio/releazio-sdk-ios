//
//  ReleazioUpdatePromptView.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import SwiftUI

/// SwiftUI view for Releazio update prompt
/// Supports update types 2 (popup) and 3 (popup force)
/// Supports two styles: InAppUpdate and Native iOS Alert
public struct ReleazioUpdatePromptView: View {
    
    // MARK: - Properties
    
    /// Update state from checkUpdates()
    public let updateState: UpdateState
    
    /// Theme configuration
    public let theme: UpdatePromptTheme
    
    /// Custom colors for component
    private let customColors: UIComponentColors?
    
    /// Custom localization strings
    private let customStrings: UILocalizationStrings?
    
    /// Localization manager (with auto-detected locale)
    private let localization: LocalizationManager
    
    /// Callback when user chooses to update
    public let onUpdate: (() -> Void)?
    
    /// Callback when user skips (type 3 only)
    public let onSkip: ((Int) -> Void)?
    
    /// Callback when user closes (type 2 only)
    public let onClose: (() -> Void)?
    
    /// Callback when user taps info/link button
    public let onInfoTap: (() -> Void)?
    
    @State private var remainingSkipAttempts: Int
    @Environment(\.colorScheme) private var systemColorScheme
    
    // MARK: - Initialization
    
    /// Initialize update prompt view
    /// - Parameters:
    ///   - updateState: Update state from checkUpdates()
    ///   - style: Update prompt style (default: .native)
    ///   - customColors: Custom colors for buttons and text (optional)
    ///   - customStrings: Custom localization strings (optional)
    ///   - onUpdate: Update action
    ///   - onSkip: Skip action (for type 3)
    ///   - onClose: Close action (for type 2)
    ///   - onInfoTap: Info button action (opens post_url)
    public init(
        updateState: UpdateState,
        style: UpdatePromptStyle = .default,
        customColors: UIComponentColors? = nil,
        customStrings: UILocalizationStrings? = nil,
        onUpdate: (() -> Void)?,
        onSkip: ((Int) -> Void)? = nil,
        onClose: (() -> Void)? = nil,
        onInfoTap: (() -> Void)? = nil
    ) {
        self.updateState = updateState
        // Default to light, will use system color scheme via environment
        self.theme = UpdatePromptTheme(style: style, colorScheme: .light)
        self.customColors = customColors
        self.customStrings = customStrings
        // Auto-detect locale from system
        let detectedLocale = LocalizationManager.detectSystemLocale()
        self.localization = LocalizationManager(locale: detectedLocale)
        self.onUpdate = onUpdate
        self.onSkip = onSkip
        self.onClose = onClose
        self.onInfoTap = onInfoTap
        self._remainingSkipAttempts = State(initialValue: updateState.remainingSkipAttempts)
    }
    
    // MARK: - Body
    
    @ViewBuilder
    public var body: some View {
        let effectiveTheme = UpdatePromptTheme(style: theme.style, colorScheme: systemColorScheme)
        
        if theme.style == .inAppUpdate {
            inAppUpdateStyleView(theme: effectiveTheme)
        } else {
            nativeStyleView(theme: effectiveTheme)
        }
    }
    
    // MARK: - Native iOS Alert Style
    
    private func nativeStyleView(theme: UpdatePromptTheme) -> some View {
        ZStack {
            // Background overlay
            theme.overlayColor
                .ignoresSafeArea()
                .allowsHitTesting(updateState.updateType == 2)  // Block taps for type 3
                .onTapGesture {
                    if updateState.updateType == 2 {
                        onClose?()
                    }
                }
            
            // Modal card
            VStack(spacing: 0) {
                // Header
                ZStack {
                    // Title (always centered)
                    Text(updateTitle)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(theme.textColor)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Buttons overlay
                    HStack {
                        // Info button (left)
                        if updateState.channelData.postUrl != nil {
                            Button(action: {
                                onInfoTap?()
                            }) {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 20))
                                    .frame(width: 24, height: 24)
                            }
                        }
                        
                        Spacer()
                        
                        // Close button (right, only for type 2)
                        if updateState.updateType == 2 {
                            Button(action: {
                                onClose?()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(theme.closeButtonColor)
                                    .frame(width: 24, height: 24)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Message
                Text(updateState.channelData.updateMessage.isEmpty ? updateMessage : updateState.channelData.updateMessage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                
                // Update button
                Button(action: {
                    onUpdate?()
                }) {
                    Text(updateButtonText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(updateButtonTextColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(updateButtonColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, updateState.updateType == 3 && remainingSkipAttempts > 0 ? 12 : 20)
                
                // Skip button (for type 3)
                if updateState.updateType == 3 && remainingSkipAttempts > 0 {
                    Button(action: {
                        let newRemaining = remainingSkipAttempts - 1
                        remainingSkipAttempts = newRemaining
                        onSkip?(newRemaining)
                        // "Skip" means close the popup
                        onClose?()
                    }) {
                        Text(skipButtonText + " (\(remainingSkipAttempts))")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.secondaryTextColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(theme.backgroundColor)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            .padding(20)
            .frame(maxWidth: 500)  // Max 500pt on large screens (iPad)
        }
        .frame(maxWidth: .infinity)  // Allow centering
    }
    
    // MARK: - InAppUpdate Style (Full Screen)
    
    private func inAppUpdateStyleView(theme: UpdatePromptTheme) -> some View {
        VStack(spacing: 0) {
            // Red header
            HStack {
                // Close button
                if updateState.updateType == 2 {
                    Button(action: {
                        onClose?()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(theme.headerTextColor)
                            .frame(width: 32, height: 32)
                    }
                } else {
                    Spacer()
                        .frame(width: 32, height: 32)
                }
                
                Spacer()
                
                // Title
                VStack(spacing: 4) {
                    Text(updateTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(theme.headerTextColor)
                    
                    // Version info
                    Text("\(updateState.currentVersion) → \(updateState.latestVersion)")
                        .font(.system(size: 14))
                        .foregroundColor(theme.headerTextColor.opacity(0.9))
                }
                
                Spacer()
                
                // Update button in header
                Button(action: {
                    onUpdate?()
                }) {
                    Text(updateButtonText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(updateButtonTextColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(updateButtonColor)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(theme.headerBackgroundColor)
            
            // Content area
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Message
                        Text(updateState.channelData.updateMessage.isEmpty ? updateMessage : updateState.channelData.updateMessage)
                            .font(.system(size: 16))
                            .foregroundColor(theme.textColor)
                            .lineSpacing(4)
                        
                        // Skip attempts (for type 3)
                        if updateState.updateType == 3 && remainingSkipAttempts > 0 {
                            Text(skipRemainingText)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.orange)
                                .padding(.top, 8)
                        }
                    }
                    .padding(20)
                }
                
                // Skip button (for type 3)
                if updateState.updateType == 3 && remainingSkipAttempts > 0 {
                    Button(action: {
                        let newRemaining = remainingSkipAttempts - 1
                        remainingSkipAttempts = newRemaining
                        onSkip?(newRemaining)
                        // "Skip" means close the popup
                        onClose?()
                    }) {
                        Text(skipButtonText)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .background(theme.backgroundColor)
        }
        .ignoresSafeArea(.all, edges: .top)
    }
    
    // MARK: - Computed Properties for Custom Strings and Colors
    
    private var updateTitle: String {
        return customStrings?.updateTitle ?? localization.updateTitle
    }
    
    private var updateMessage: String {
        return customStrings?.updateMessage ?? localization.updateMessage
    }
    
    private var updateButtonText: String {
        return customStrings?.updateButtonText ?? localization.updateButtonText
    }
    
    private var skipButtonText: String {
        return customStrings?.skipButtonText ?? localization.skipButtonText
    }
    
    private var closeButtonText: String {
        return customStrings?.closeButtonText ?? localization.closeButtonText
    }
    
    private var whatsNewText: String {
        return customStrings?.whatsNewText ?? localization.whatsNewText
    }
    
    private var skipRemainingText: String {
        if let customFormat = customStrings?.skipRemainingTextFormat {
            return String(format: customFormat, remainingSkipAttempts)
        }
        return localization.skipRemainingText(count: remainingSkipAttempts)
    }
    
    private var updateButtonColor: Color {
        if let customColor = customColors?.updateButtonColor {
            #if canImport(UIKit)
            return Color(customColor)
            #else
            return customColor
            #endif
        }
        return theme.primaryButtonColor
    }
    
    private var updateButtonTextColor: Color {
        if let customColor = customColors?.updateButtonTextColor {
            #if canImport(UIKit)
            return Color(customColor)
            #else
            return customColor
            #endif
        }
        return theme.primaryButtonTextColor
    }
    
    private var linkColor: Color {
        if let customColor = customColors?.linkColor {
            #if canImport(UIKit)
            return Color(customColor)
            #else
            return customColor
            #endif
        }
        return theme.linkColor
    }
}
