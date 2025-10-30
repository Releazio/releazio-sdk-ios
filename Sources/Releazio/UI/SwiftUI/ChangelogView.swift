//
//  ChangelogView.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import SwiftUI
import WebKit
#if canImport(UIKit)
import UIKit
#endif

/// SwiftUI view for displaying changelog
public struct ChangelogView: View {

    // MARK: - Properties

    /// Changelog to display
    @State public var changelog: Changelog

    /// Theme configuration
    public let theme: ChangelogTheme

    /// Dismiss action
    public let onDismiss: (() -> Void)?
    
    @State private var postURL: String? = nil
    @State private var isLoading = true
    @State private var hasLoadedURL = false

    // MARK: - Initialization

    /// Initialize changelog view
    /// - Parameters:
    ///   - changelog: Changelog to display
    ///   - theme: Theme configuration
    ///   - onDismiss: Dismiss action
    public init(
        changelog: Changelog,
        theme: ChangelogTheme = .default,
        onDismiss: (() -> Void)? = nil
    ) {
        self.changelog = changelog
        self.theme = theme
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    public var body: some View {
        if #available(macOS 13.0, iOS 16.0, *) {
            NavigationStack {
                contentView
            }
        } else {
            NavigationView {
                contentView
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Header
                headerView

                // Content
                changelogContentView

                // Footer
                if let author = changelog.author {
                    authorView(author)
                }
            }
            .padding()
        }
        .background(theme.backgroundColor.ignoresSafeArea())
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                if onDismiss != nil {
                    Button("Done") {
                        onDismiss?()
                    }
                    .foregroundColor(theme.primaryColor)
                }
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                if onDismiss != nil {
                    Button("Done") {
                        onDismiss?()
                    }
                    .foregroundColor(theme.primaryColor)
                }
            }
            #endif
        }
        #if !os(macOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(spacing: 12) {
            // Title
            Text(changelog.title)
                .font(theme.titleFont)
                .foregroundColor(theme.titleColor)
                .multilineTextAlignment(.center)

            // Date
            Text(changelog.formattedCreationDate)
                .font(theme.dateFont)
                .foregroundColor(theme.subtitleColor)

            // Divider
            Rectangle()
                .fill(theme.dividerColor)
                .frame(height: 1)
                .padding(.horizontal)
        }
        .padding(.bottom, 20)
    }

    private var changelogContentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let urlString = postURL {
                #if canImport(UIKit)
                WebView(url: urlString, isLoading: $isLoading)
                    .frame(minWidth: 300, minHeight: 400)
                    .cornerRadius(12)
                    .background(Color.gray.opacity(0.1))
                #else
                Text("WebView not available on this platform")
                    .foregroundColor(.secondary)
                #endif
            } else {
                VStack {
                    ProgressView("Loading URL...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .onAppear {
            // Если postURL не передан через инициализатор, используем content из changelog
            if !hasLoadedURL && postURL == nil {
                hasLoadedURL = true
                // Просто используем content из changelog как URL (он уже загружен в ContentView)
                self.postURL = changelog.content
                self.isLoading = false
                print("✅ Using changelog.content as URL: \(changelog.content)")
            }
        }
    }
    
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return
        }
        
        #if canImport(UIKit)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            print("🌐 Opening URL in browser: \(urlString)")
        } else {
            print("❌ Cannot open URL: \(urlString)")
        }
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        print("🌐 Opening URL in browser: \(urlString)")
        #else
        print("❌ Cannot open URL on this platform: \(urlString)")
        #endif
    }

    private func categorySection(_ category: ChangelogCategory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category header
            HStack {
                Image(systemName: category.iconName)
                    .foregroundColor(categoryColor(for: category))
                    .font(.system(size: 16, weight: .medium))

                Text(category.displayName)
                    .font(theme.categoryFont)
                    .foregroundColor(theme.categoryColor)

                Spacer()

                // Entry count badge
                if let count = changelog.entryCountsByCategory[category], count > 1 {
                    Text("\(count)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(categoryColor(for: category))
                        .clipShape(Capsule())
                }
            }

            // Category entries
            VStack(alignment: .leading, spacing: 8) {
                ForEach(changelog.entries(in: category)) { entry in
                    changelogEntryView(entry)
                }
            }
        }
        .padding(.bottom, 20)
    }

    private func changelogEntryView(_ entry: ChangelogEntry) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Priority indicator
            if entry.isBreaking {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 12))
                    .padding(.top, 2)
            } else {
                Image(systemName: entry.priority == .critical ? "exclamationmark.circle.fill" : "circle.fill")
                    .foregroundColor(priorityColor(for: entry.priority))
                    .font(.system(size: 8))
                    .padding(.top, 6)
            }

            VStack(alignment: .leading, spacing: 4) {
                // Entry title (if available)
                if let title = entry.title, !title.isEmpty {
                    Text(title)
                        .font(theme.entryTitleFont)
                        .foregroundColor(theme.entryTitleColor)
                        .fontWeight(.medium)
                }

                // Entry description
                Text(entry.description)
                    .font(theme.entryDescriptionFont)
                    .foregroundColor(theme.entryDescriptionColor)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func authorView(_ author: Author) -> some View {
        HStack(spacing: 12) {
            // Avatar
            AsyncImage(url: author.avatarURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(theme.subtitleColor.opacity(0.3))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(theme.subtitleColor.opacity(0.6))
                            .font(.system(size: 20))
                    )
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            // Author info
            VStack(alignment: .leading, spacing: 2) {
                Text(author.name)
                    .font(theme.authorNameFont)
                    .foregroundColor(theme.authorNameColor)

                if let role = author.role {
                    Text(role)
                        .font(theme.authorRoleFont)
                        .foregroundColor(theme.authorRoleColor)
                }
            }

            Spacer()
        }
        .padding(.top, 20)
        .padding(.horizontal, 8)
    }

    // MARK: - Helper Methods

    private func categoryColor(for category: ChangelogCategory) -> Color {
        switch category {
        case .feature:
            return .blue
        case .improvement:
            return .green
        case .bugfix:
            return .orange
        case .security:
            return .red
        case .performance:
            return .purple
        case .ui:
            return .pink
        case .api:
            return .indigo
        case .documentation:
            return .gray
        case .other:
            return .secondary
        }
    }

    private func priorityColor(for priority: EntryPriority) -> Color {
        switch priority {
        case .critical:
            return .red
        case .high:
            return .orange
        case .normal:
            return theme.primaryColor
        case .low:
            return theme.subtitleColor
        }
    }
    
    // MARK: - WebView
    
    #if canImport(UIKit)
    private struct WebView: UIViewRepresentable {
        let url: String
        @Binding var isLoading: Bool
        
        func makeUIView(context: Context) -> WKWebView {
            let webView = WKWebView()
            webView.navigationDelegate = context.coordinator
            #if os(iOS)
            webView.allowsBackForwardNavigationGestures = true
            webView.scrollView.isScrollEnabled = true
            #endif
            print("🌐 WebView created")
            return webView
        }
        
        func updateUIView(_ webView: WKWebView, context: Context) {
            print("🌐 WebView updateUIView called with URL: \(url)")
            guard let url = URL(string: url) else { 
                print("❌ Invalid URL: \(url)")
                return 
            }
            
            // Загружаем URL только если он отличается от текущего
            if webView.url?.absoluteString != url.absoluteString {
                print("🌐 WebView loading new URL: \(url)")
                let request = URLRequest(url: url)
                webView.load(request)
            } else {
                print("🌐 WebView URL already loaded: \(url)")
            }
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(isLoading: $isLoading)
        }
        
        class Coordinator: NSObject, WKNavigationDelegate {
            @Binding var isLoading: Bool
            private var loadingTimer: Timer?
            
            init(isLoading: Binding<Bool>) {
                self._isLoading = isLoading
            }
            
            func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
                print("🌐 WebView started loading")
                isLoading = true
                
                // Таймаут на 15 секунд
                loadingTimer?.invalidate()
                loadingTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { _ in
                    print("⏰ WebView loading timeout")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
            
            func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
                print("🌐 WebView did commit navigation")
                // Дополнительная проверка через 2 секунды
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if !webView.isLoading {
                        print("✅ WebView content loaded (didCommit)")
                        self.loadingTimer?.invalidate()
                        self.isLoading = false
                    }
                }
            }
            
            func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                print("✅ WebView finished loading")
                print("🌐 WebView current URL: \(webView.url?.absoluteString ?? "nil")")
                print("🌐 WebView canGoBack: \(webView.canGoBack)")
                print("🌐 WebView canGoForward: \(webView.canGoForward)")
                loadingTimer?.invalidate()
                isLoading = false
            }
            
            func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
                print("❌ WebView failed to load: \(error)")
                loadingTimer?.invalidate()
                isLoading = false
            }
            
            func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
                print("❌ WebView failed provisional navigation: \(error)")
                loadingTimer?.invalidate()
                isLoading = false
            }
        }
    }
    #endif
}

// MARK: - Changelog Theme

public struct ChangelogTheme {
    public let backgroundColor: Color
    public let primaryColor: Color
    public let titleColor: Color
    public let subtitleColor: Color
    public let categoryColor: Color
    public let entryTitleColor: Color
    public let entryDescriptionColor: Color
    public let authorNameColor: Color
    public let authorRoleColor: Color
    public let dividerColor: Color
    public let titleFont: Font
    public let dateFont: Font
    public let categoryFont: Font
    public let entryTitleFont: Font
    public let entryDescriptionFont: Font
    public let authorNameFont: Font
    public let authorRoleFont: Font

    public init(
        backgroundColor: Color = Color.systemBackground,
        primaryColor: Color = .blue,
        titleColor: Color = Color.label,
        subtitleColor: Color = Color.secondaryLabel,
        categoryColor: Color = Color.label,
        entryTitleColor: Color = Color.label,
        entryDescriptionColor: Color = Color.secondaryLabel,
        authorNameColor: Color = Color.label,
        authorRoleColor: Color = Color.secondaryLabel,
        dividerColor: Color = Color.separator,
        titleFont: Font = .title2.bold(),
        dateFont: Font = .caption,
        categoryFont: Font = .headline,
        entryTitleFont: Font = .subheadline.weight(.medium),
        entryDescriptionFont: Font = .body,
        authorNameFont: Font = .caption.weight(.medium),
        authorRoleFont: Font = .caption2
    ) {
        self.backgroundColor = backgroundColor
        self.primaryColor = primaryColor
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.categoryColor = categoryColor
        self.entryTitleColor = entryTitleColor
        self.entryDescriptionColor = entryDescriptionColor
        self.authorNameColor = authorNameColor
        self.authorRoleColor = authorRoleColor
        self.dividerColor = dividerColor
        self.titleFont = titleFont
        self.dateFont = dateFont
        self.categoryFont = categoryFont
        self.entryTitleFont = entryTitleFont
        self.entryDescriptionFont = entryDescriptionFont
        self.authorNameFont = authorNameFont
        self.authorRoleFont = authorRoleFont
    }

    /// Default theme
    public static let `default` = ChangelogTheme()

    /// Dark theme
    public static let dark = ChangelogTheme(
        backgroundColor: Color.systemBackground,
        primaryColor: .orange,
        titleColor: Color.label,
        subtitleColor: Color.secondaryLabel,
        categoryColor: Color.label,
        entryTitleColor: Color.label,
        entryDescriptionColor: Color.secondaryLabel,
        authorNameColor: Color.label,
        authorRoleColor: Color.secondaryLabel,
        dividerColor: Color.separator
    )

    /// Custom brand theme
    public static func brand(
        primaryColor: Color,
        backgroundColor: Color = Color.systemBackground
    ) -> ChangelogTheme {
        return ChangelogTheme(
            backgroundColor: backgroundColor,
            primaryColor: primaryColor
        )
    }
}

// MARK: - Preview

struct ChangelogView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleChangelog = Changelog(
            id: "1",
            releaseId: "release-1",
            title: "Version 2.0.0",
            content: "Major update with new features",
            entries: [
                ChangelogEntry(
                    title: "New Feature",
                    description: "Added exciting new functionality that users will love",
                    category: .feature,
                    priority: .high
                ),
                ChangelogEntry(
                    title: "Bug Fix",
                    description: "Fixed critical bug that was causing crashes",
                    category: .bugfix,
                    priority: .critical,
                    isBreaking: true
                )
            ],
            author: Author(
                name: "John Doe",
                role: "iOS Developer"
            )
        )

        Group {
            ChangelogView(changelog: sampleChangelog)
                .previewDisplayName("Light Mode")

            ChangelogView(changelog: sampleChangelog, theme: .dark)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}