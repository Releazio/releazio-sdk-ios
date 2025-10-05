//
//  UpdatePromptView.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import SwiftUI

/// SwiftUI view for prompting app updates
public struct UpdatePromptView: View {

    // MARK: - Properties

    /// Release information for the update
    public let release: Release

    /// Update type
    public let updateType: UpdateType

    /// Whether this is a mandatory update
    public let isMandatory: Bool

    /// Theme configuration
    public let theme: LegacyUpdatePromptTheme

    /// Callback when user chooses to update
    public let onUpdate: (() -> Void)?

    /// Callback when user dismisses (if allowed)
    public let onDismiss: (() -> Void)?

    /// Show changelog
    @State private var showChangelog = false

    // MARK: - Initialization

    /// Initialize update prompt view
    /// - Parameters:
    ///   - release: Release information
    ///   - updateType: Type of update
    ///   - isMandatory: Whether update is mandatory
    ///   - theme: Theme configuration
    ///   - onUpdate: Update action
    ///   - onDismiss: Dismiss action (ignored for mandatory updates)
    public init(
        release: Release,
        updateType: UpdateType,
        isMandatory: Bool = false,
        theme: LegacyUpdatePromptTheme = .default,
        onUpdate: (() -> Void)?,
        onDismiss: (() -> Void)? = nil
    ) {
        self.release = release
        self.updateType = updateType
        self.isMandatory = isMandatory
        self.theme = theme
        self.onUpdate = onUpdate
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            // Background overlay
            theme.overlayColor
                .ignoresSafeArea()
                .onTapGesture {
                    if !isMandatory {
                        onDismiss?()
                    }
                }

            // Update prompt card
            VStack(spacing: 0) {
                headerView

                Divider()
                    .background(theme.dividerColor)

                contentView

                Divider()
                    .background(theme.dividerColor)

                actionButtonsView
            }
            .background(theme.backgroundColor)
            .cornerRadius(theme.cornerRadius)
            .shadow(color: theme.shadowColor, radius: theme.shadowRadius, x: 0, y: theme.shadowY)
            .padding(theme.cardPadding)
            .scaleEffect(showChangelog ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: showChangelog)
        }
        .sheet(isPresented: $showChangelog) {
            // Changelog sheet would be presented here
            Text("Changelog view would be shown here")
                .padding()
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(spacing: 12) {
            // Icon and title
            HStack(spacing: 16) {
                Image(systemName: headerIconName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(headerIconColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(headerTitle)
                        .font(theme.titleFont)
                        .foregroundColor(theme.titleColor)

                    Text(release.versionWithBuild)
                        .font(theme.versionFont)
                        .foregroundColor(theme.versionColor)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // Update size (if available)
            if let formattedSize = release.formattedUpdateSize {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(theme.primaryColor)
                        .font(.system(size: 14))

                    Text("Download size: \(formattedSize)")
                        .font(theme.sizeFont)
                        .foregroundColor(theme.subtitleColor)

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 16)
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Update message
            Text(updateMessage)
                .font(theme.messageFont)
                .foregroundColor(theme.messageColor)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            // Release notes preview
            if let releaseNotes = release.releaseNotes, !releaseNotes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: {
                        showChangelog = true
                    }) {
                        HStack {
                            Text("What's New")
                                .font(theme.changelogTitleFont)
                                .foregroundColor(theme.primaryColor)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(theme.primaryColor)
                        }
                        .padding(.vertical, 8)
                    }

                    Text(releaseNotes)
                        .font(theme.changelogFont)
                        .foregroundColor(theme.changelogColor)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
            }

            // Mandatory update warning
            if isMandatory {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 16))

                    Text("This update is required to continue using the app.")
                        .font(theme.warningFont)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private var actionButtonsView: some View {
        HStack(spacing: 12) {
            // Dismiss button (only for non-mandatory updates)
            if !isMandatory {
                Button(action: {
                    onDismiss?()
                }) {
                    Text("Later")
                        .font(theme.buttonFont)
                        .foregroundColor(theme.secondaryButtonTextColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: theme.buttonHeight)
                        .background(theme.secondaryButtonBackgroundColor)
                        .cornerRadius(theme.buttonCornerRadius)
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Update button
            Button(action: {
                onUpdate?()
            }) {
                HStack(spacing: 8) {
                    if isMandatory {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 14, weight: .medium))
                    } else {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 14, weight: .medium))
                    }

                    Text(updateButtonText)
                        .font(theme.buttonFont)
                        .fontWeight(.semibold)
                }
                .foregroundColor(theme.primaryButtonTextColor)
                .frame(maxWidth: .infinity)
                .frame(height: theme.buttonHeight)
                .background(primaryButtonBackgroundColor)
                .cornerRadius(theme.buttonCornerRadius)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: - Computed Properties

    private var headerIconName: String {
        switch updateType {
        case .critical:
            return "exclamationmark.shield.fill"
        case .major:
            return "star.fill"
        case .minor:
            return "arrow.up.circle.fill"
        case .patch:
            return "ladybug.fill"
        case .none:
            return "info.circle.fill"
        }
    }

    private var headerIconColor: Color {
        switch updateType {
        case .critical:
            return .red
        case .major:
            return .orange
        case .minor:
            return .blue
        case .patch:
            return .green
        case .none:
            return theme.primaryColor
        }
    }

    private var headerTitle: String {
        if isMandatory {
            return "Mandatory Update Required"
        }

        switch updateType {
        case .critical:
            return "Critical Security Update"
        case .major:
            return "Major Update Available"
        case .minor:
            return "New Update Available"
        case .patch:
            return "Bug Fix Update"
        case .none:
            return "Update Available"
        }
    }

    private var updateMessage: String {
        if isMandatory {
            return "A mandatory update is required to continue using the app. Please update to the latest version to ensure you have the latest security patches and features."
        }

        switch updateType {
        case .critical:
            return "A critical security update is available that addresses important vulnerabilities. We recommend updating immediately."
        case .major:
            return "A major new version is available with exciting new features, improvements, and an enhanced user experience."
        case .minor:
            return "New features and improvements are available in this update to enhance your app experience."
        case .patch:
            return "This update includes bug fixes and performance improvements to make the app more stable."
        case .none:
            return "An update is available with improvements and new features."
        }
    }

    private var updateButtonText: String {
        if isMandatory {
            return "Update Now"
        }

        switch updateType {
        case .critical:
            return "Update Now"
        case .major:
            return "Update to Latest"
        case .minor:
            return "Update"
        case .patch:
            return "Update"
        case .none:
            return "Update"
        }
    }

    private var primaryButtonBackgroundColor: Color {
        switch updateType {
        case .critical:
            return .red
        case .major:
            return .orange
        default:
            return theme.primaryColor
        }
    }
}

// MARK: - Update Prompt Theme (Legacy)

public struct LegacyUpdatePromptTheme {
    public let backgroundColor: Color
    public let primaryColor: Color
    public let titleColor: Color
    public let subtitleColor: Color
    public let versionColor: Color
    public let messageColor: Color
    public let changelogTitleColor: Color
    public let changelogColor: Color
    public let warningColor: Color
    public let primaryButtonTextColor: Color
    public let primaryButtonBackgroundColor: Color
    public let secondaryButtonTextColor: Color
    public let secondaryButtonBackgroundColor: Color
    public let dividerColor: Color
    public let overlayColor: Color
    public let shadowColor: Color
    public let cornerRadius: CGFloat
    public let shadowRadius: CGFloat
    public let shadowY: CGFloat
    public let cardPadding: EdgeInsets
    public let buttonHeight: CGFloat
    public let buttonCornerRadius: CGFloat
    public let titleFont: Font
    public let versionFont: Font
    public let sizeFont: Font
    public let messageFont: Font
    public let changelogTitleFont: Font
    public let changelogFont: Font
    public let warningFont: Font
    public let buttonFont: Font

    public init(
        backgroundColor: Color = Color.systemBackground,
        primaryColor: Color = .blue,
        titleColor: Color = Color.label,
        subtitleColor: Color = Color.secondaryLabel,
        versionColor: Color = Color.secondaryLabel,
        messageColor: Color = Color.label,
        changelogTitleColor: Color = .blue,
        changelogColor: Color = Color.secondaryLabel,
        warningColor: Color = .red,
        primaryButtonTextColor: Color = .white,
        primaryButtonBackgroundColor: Color = .blue,
        secondaryButtonTextColor: Color = Color.label,
        secondaryButtonBackgroundColor: Color = Color.secondarySystemFill,
        dividerColor: Color = Color.separator,
        overlayColor: Color = Color.black.opacity(0.3),
        shadowColor: Color = Color.black.opacity(0.1),
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 10,
        shadowY: CGFloat = 5,
        cardPadding: EdgeInsets = EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20),
        buttonHeight: CGFloat = 50,
        buttonCornerRadius: CGFloat = 12,
        titleFont: Font = .title2.bold(),
        versionFont: Font = .subheadline,
        sizeFont: Font = .caption,
        messageFont: Font = .body,
        changelogTitleFont: Font = .subheadline.weight(.medium),
        changelogFont: Font = .caption,
        warningFont: Font = .subheadline,
        buttonFont: Font = .body.weight(.medium)
    ) {
        self.backgroundColor = backgroundColor
        self.primaryColor = primaryColor
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.versionColor = versionColor
        self.messageColor = messageColor
        self.changelogTitleColor = changelogTitleColor
        self.changelogColor = changelogColor
        self.warningColor = warningColor
        self.primaryButtonTextColor = primaryButtonTextColor
        self.primaryButtonBackgroundColor = primaryButtonBackgroundColor
        self.secondaryButtonTextColor = secondaryButtonTextColor
        self.secondaryButtonBackgroundColor = secondaryButtonBackgroundColor
        self.dividerColor = dividerColor
        self.overlayColor = overlayColor
        self.shadowColor = shadowColor
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.shadowY = shadowY
        self.cardPadding = cardPadding
        self.buttonHeight = buttonHeight
        self.buttonCornerRadius = buttonCornerRadius
        self.titleFont = titleFont
        self.versionFont = versionFont
        self.sizeFont = sizeFont
        self.messageFont = messageFont
        self.changelogTitleFont = changelogTitleFont
        self.changelogFont = changelogFont
        self.warningFont = warningFont
        self.buttonFont = buttonFont
    }

    /// Default theme
    public static let `default` = LegacyUpdatePromptTheme()

    /// Dark theme
    public static let dark = LegacyUpdatePromptTheme(
        backgroundColor: Color.secondarySystemFill,
        primaryColor: .orange,
        primaryButtonBackgroundColor: .orange
    )
}

// MARK: - Update Prompt Manager

public class UpdatePromptManager: ObservableObject {
    @Published public var shouldShowPrompt = false
    @Published public var updateInfo: UpdateInfo?

    private let releaseService: ReleaseServiceProtocol

    public init(releaseService: ReleaseServiceProtocol) {
        self.releaseService = releaseService
    }

    /// Check for updates and show prompt if needed
    /// - Parameters:
    ///   - applicationId: Application ID
    ///   - environment: Environment
    public func checkForUpdatesAndShowPrompt(
        applicationId: String,
        environment: String
    ) async {
        do {
            let currentAppVersion = Bundle.main.appVersion ?? AppVersion(major: 0, minor: 0, patch: 0)
            let currentVersion = currentAppVersion.versionString
            let updateInfo = try await releaseService.getUpdateInfo(
                currentVersion: currentVersion
            )

            await MainActor.run {
                self.updateInfo = updateInfo
                self.shouldShowPrompt = updateInfo.shouldShowPrompt || updateInfo.hasUpdate
            }
        } catch {
            if Releazio.shared.getConfiguration()?.debugLoggingEnabled == true {
                print("Failed to check for updates: \(error)")
            }
        }
    }
}

// MARK: - Preview

struct UpdatePromptView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleRelease = Release(
            id: "1",
            version: "2.0.0",
            title: "Major Update",
            description: "Exciting new features",
            releaseNotes: "• New feature A\n• Improved performance\n• Bug fixes",
            releaseDate: Date(),
            isMandatory: false
        )

        Group {
            UpdatePromptView(
                release: sampleRelease,
                updateType: .major,
                isMandatory: false,
                onUpdate: {},
                onDismiss: {}
            )
            .previewDisplayName("Major Update")

            UpdatePromptView(
                release: sampleRelease,
                updateType: .critical,
                isMandatory: true,
                theme: .default,
                onUpdate: {},
                onDismiss: {}
            )
            .previewDisplayName("Mandatory Critical Update")
        }
    }
}