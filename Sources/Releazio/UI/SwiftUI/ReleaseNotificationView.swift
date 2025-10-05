//
//  ReleaseNotificationView.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import SwiftUI

/// SwiftUI view for showing small release notifications
public struct ReleaseNotificationView: View {

    // MARK: - Properties

    /// Release information
    public let release: Release

    /// Notification type
    public let notificationType: NotificationType

    /// Theme configuration
    public let theme: NotificationTheme

    /// Callback when notification is tapped
    public let onTap: (() -> Void)?

    /// Callback when notification is dismissed
    public let onDismiss: (() -> Void)?

    /// Animation state
    @State private var isVisible = false
    @State private var offset: CGFloat = 0

    // MARK: - Initialization

    /// Initialize notification view
    /// - Parameters:
    ///   - release: Release information
    ///   - notificationType: Type of notification
    ///   - theme: Theme configuration
    ///   - onTap: Tap action
    ///   - onDismiss: Dismiss action
    public init(
        release: Release,
        notificationType: NotificationType = .newUpdate,
        theme: NotificationTheme = .default,
        onTap: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.release = release
        self.notificationType = notificationType
        self.theme = theme
        self.onTap = onTap
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 12) {
            // Icon
            iconView

            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(notificationTitle)
                    .font(theme.titleFont)
                    .foregroundColor(theme.titleColor)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                // Subtitle
                Text(notificationSubtitle)
                    .font(theme.subtitleFont)
                    .foregroundColor(theme.subtitleColor)
                    .lineLimit(2)
            }

            Spacer()

            // Dismiss button
            if onDismiss != nil {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isVisible = false
                        offset = -100
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDismiss?()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(theme.dismissButtonColor)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .fill(theme.backgroundColor)
                .shadow(color: theme.shadowColor, radius: theme.shadowRadius, x: 0, y: theme.shadowY)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .stroke(borderColor, lineWidth: theme.borderWidth)
        )
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: offset)
        .onTapGesture {
            onTap?()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isVisible = true
                offset = 0
            }
        }
    }

    // MARK: - Subviews

    private var iconView: some View {
        ZStack {
            Circle()
                .fill(iconBackgroundColor)
                .frame(width: 32, height: 32)

            Image(systemName: iconName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(iconForegroundColor)
        }
    }

    // MARK: - Computed Properties

    private var notificationTitle: String {
        switch notificationType {
        case .newUpdate:
            return "Update Available"
        case .mandatoryUpdate:
            return "Required Update"
        case .criticalUpdate:
            return "Critical Update"
        case .downloadComplete:
            return "Download Ready"
        case .custom(let title, _):
            return title
        }
    }

    private var notificationSubtitle: String {
        switch notificationType {
        case .newUpdate, .mandatoryUpdate, .criticalUpdate:
            return "Version \(release.versionWithBuild) is now available"
        case .downloadComplete:
            return "Tap to install the update"
        case .custom(_, let subtitle):
            return subtitle
        }
    }

    private var iconName: String {
        switch notificationType {
        case .newUpdate:
            return "arrow.down.circle.fill"
        case .mandatoryUpdate:
            return "exclamationmark.triangle.fill"
        case .criticalUpdate:
            return "exclamationmark.shield.fill"
        case .downloadComplete:
            return "checkmark.circle.fill"
        case .custom(let iconName, _):
            return iconName
        }
    }

    private var iconBackgroundColor: Color {
        switch notificationType {
        case .newUpdate:
            return theme.primaryColor.opacity(0.2)
        case .mandatoryUpdate:
            return .orange.opacity(0.2)
        case .criticalUpdate:
            return .red.opacity(0.2)
        case .downloadComplete:
            return .green.opacity(0.2)
        case .custom:
            return theme.primaryColor.opacity(0.2)
        }
    }

    private var iconForegroundColor: Color {
        switch notificationType {
        case .newUpdate:
            return theme.primaryColor
        case .mandatoryUpdate:
            return .orange
        case .criticalUpdate:
            return .red
        case .downloadComplete:
            return .green
        case .custom:
            return theme.primaryColor
        }
    }

    private var borderColor: Color {
        switch notificationType {
        case .criticalUpdate:
            return .red.opacity(0.5)
        case .mandatoryUpdate:
            return .orange.opacity(0.5)
        default:
            return Color.clear
        }
    }
}

// MARK: - Notification Type

public enum NotificationType {
    case newUpdate
    case mandatoryUpdate
    case criticalUpdate
    case downloadComplete
    case custom(iconName: String, subtitle: String)
}

// MARK: - Notification Theme

public struct NotificationTheme {
    public let backgroundColor: Color
    public let primaryColor: Color
    public let titleColor: Color
    public let subtitleColor: Color
    public let dismissButtonColor: Color
    public let shadowColor: Color
    public let cornerRadius: CGFloat
    public let shadowRadius: CGFloat
    public let shadowY: CGFloat
    public let borderWidth: CGFloat
    public let titleFont: Font
    public let subtitleFont: Font

    public init(
        backgroundColor: Color = Color.systemBackground,
        primaryColor: Color = .blue,
        titleColor: Color = Color.label,
        subtitleColor: Color = Color.secondaryLabel,
        dismissButtonColor: Color = Color.tertiaryLabel,
        shadowColor: Color = Color.black.opacity(0.1),
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 4,
        shadowY: CGFloat = 2,
        borderWidth: CGFloat = 1,
        titleFont: Font = .subheadline.weight(.medium),
        subtitleFont: Font = .caption
    ) {
        self.backgroundColor = backgroundColor
        self.primaryColor = primaryColor
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.dismissButtonColor = dismissButtonColor
        self.shadowColor = shadowColor
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.shadowY = shadowY
        self.borderWidth = borderWidth
        self.titleFont = titleFont
        self.subtitleFont = subtitleFont
    }

    /// Default theme
    public static let `default` = NotificationTheme()

    /// Dark theme
    public static let dark = NotificationTheme(
        backgroundColor: Color.secondarySystemBackground,
        primaryColor: .orange
    )

    /// Prominent theme for important notifications
    public static let prominent = NotificationTheme(
        backgroundColor: Color.systemBackground,
        primaryColor: .red,
        titleColor: Color.label,
        subtitleColor: Color.secondaryLabel,
        shadowRadius: 8,
        shadowY: 4
    )
}

// MARK: - Notification Manager

public class NotificationManager: ObservableObject {
    @Published public var currentNotification: NotificationInfo?
    @Published public var isVisible = false

    private var dismissTimer: Timer?

    public init() {}

    /// Show notification
    /// - Parameters:
    ///   - notification: Notification to show
    ///   - duration: Auto-dismiss duration in seconds (nil for manual dismiss only)
    public func show(_ notification: NotificationInfo, duration: TimeInterval? = 5) {
        // Hide any existing notification
        hide()

        // Show new notification
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            currentNotification = notification
            isVisible = true
        }

        // Auto-dismiss if duration is specified
        if let duration = duration {
            dismissTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
                self.hide()
            }
        }
    }

    /// Hide current notification
    public func hide() {
        dismissTimer?.invalidate()
        dismissTimer = nil

        withAnimation(.easeInOut(duration: 0.3)) {
            isVisible = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.currentNotification = nil
        }
    }

    /// Show new update notification
    /// - Parameters:
    ///   - release: Release information
    ///   - isMandatory: Whether update is mandatory
    ///   - onTap: Tap action
    ///   - onDismiss: Dismiss action
    public func showNewUpdate(
        release: Release,
        isMandatory: Bool = false,
        onTap: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        let notificationType: NotificationType = isMandatory ? .mandatoryUpdate : .newUpdate
        let notification = NotificationInfo(
            release: release,
            type: notificationType,
            onTap: onTap,
            onDismiss: onDismiss
        )
        show(notification)
    }

    /// Show critical update notification
    /// - Parameters:
    ///   - release: Release information
    ///   - onTap: Tap action
    ///   - onDismiss: Dismiss action
    public func showCriticalUpdate(
        release: Release,
        onTap: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        let notification = NotificationInfo(
            release: release,
            type: .criticalUpdate,
            theme: .prominent,
            onTap: onTap,
            onDismiss: onDismiss
        )
        show(notification, duration: nil) // No auto-dismiss for critical updates
    }

    /// Show download complete notification
    /// - Parameters:
    ///   - release: Release information
    ///   - onTap: Tap action
    public func showDownloadComplete(
        release: Release,
        onTap: (() -> Void)? = nil
    ) {
        let notification = NotificationInfo(
            release: release,
            type: .downloadComplete,
            onTap: onTap,
            onDismiss: nil
        )
        show(notification, duration: 8) // Longer duration for download complete
    }
}

// MARK: - Notification Info

public struct NotificationInfo {
    public let release: Release
    public let type: NotificationType
    public let theme: NotificationTheme
    public let onTap: (() -> Void)?
    public let onDismiss: (() -> Void)?

    public init(
        release: Release,
        type: NotificationType,
        theme: NotificationTheme = .default,
        onTap: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.release = release
        self.type = type
        self.theme = theme
        self.onTap = onTap
        self.onDismiss = onDismiss
    }
}

// MARK: - Container View for Notifications

public struct NotificationContainerView: View {
    @StateObject private var notificationManager = NotificationManager()
    @State private var topOffset: CGFloat = 0

    public init() {}

    public var body: some View {
        VStack {
            if let notification = notificationManager.currentNotification,
               notificationManager.isVisible {
                ReleaseNotificationView(
                    release: notification.release,
                    notificationType: notification.type,
                    theme: notification.theme,
                    onTap: notification.onTap,
                    onDismiss: notification.onDismiss
                )
                .padding(.horizontal)
                .padding(.top, topOffset)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            Spacer()
        }
        .onAppear {
            // Handle safe area insets
            #if canImport(UIKit)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                topOffset = window.safeAreaInsets.top + 8
            }
            #endif
        }
    }
}

// MARK: - Preview

struct ReleaseNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleRelease = Release(
            id: "1",
            version: "2.0.0",
            title: "Major Update",
            description: "Exciting new features",
            releaseDate: Date()
        )

        Group {
            ReleaseNotificationView(
                release: sampleRelease,
                notificationType: .newUpdate,
                onTap: {},
                onDismiss: {}
            )
            .previewDisplayName("New Update")

            ReleaseNotificationView(
                release: sampleRelease,
                notificationType: .criticalUpdate,
                theme: .prominent,
                onTap: {},
                onDismiss: {}
            )
            .previewDisplayName("Critical Update")

            NotificationContainerView()
                .frame(height: 200)
                .previewDisplayName("Container View")
        }
    }
}