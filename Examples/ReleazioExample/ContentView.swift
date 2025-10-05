//
//  ContentView.swift
//  ReleazioExample
//
//  Created by Releazio Team on 05.10.2025.
//

import SwiftUI
import Releazio

struct ContentView: View {
    @State private var showingChangelog = false
    @State private var showingUpdatePromptNative = false
    @State private var showingUpdatePromptOlimp = false
    @State private var updateState: UpdateState?
    @State private var changelog: Changelog?
    @State private var isLoading = false
    @State private var isDarkMode = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // Header
                        headerView

                        // Quick Actions
                        quickActionsView

                        // Update Status
                        if let state = updateState {
                            updateStatusView(state)
                        }
                    }
                    .padding()
                    .padding(.bottom, 100) // Space for bottom version component
                }
                
                // Version Component внизу экрана
                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [
                            Color(.systemBackground).opacity(0),
                            Color(.systemBackground).opacity(0.9),
                            Color(.systemBackground)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 20)
                    .allowsHitTesting(false)
                    
                    bottomVersionView
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                }
                .padding(.bottom, 34) // Над таббаром
            }
            .navigationTitle("Releazio SDK Demo")
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .sheet(isPresented: $showingChangelog) {
                if let changelog = changelog {
                    NavigationView {
                        ChangelogView(changelog: changelog) {
                            showingChangelog = false
                        }
                    }
                }
            }
            .sheet(isPresented: $showingUpdatePromptNative) {
                if let state = updateState {
                    ReleazioUpdatePromptView(
                        updateState: state,
                        style: .native,
                        onUpdate: {
                            // SDK предоставляет удобный метод для открытия App Store
                            Releazio.shared.openAppStore(updateState: state)
                            showingUpdatePromptNative = false
                        },
                        onSkip: { remaining in
                            print("Skipped, remaining: \(remaining)")
                            showingUpdatePromptNative = false
                        },
                        onClose: {
                            showingUpdatePromptNative = false
                        },
                        onInfoTap: {
                            // SDK предоставляет удобный метод для открытия поста
                            Releazio.shared.openPostURL(updateState: state)
                        }
                    )
                }
            }
            .fullScreenCover(isPresented: $showingUpdatePromptOlimp) {
                if let state = updateState {
                    ReleazioUpdatePromptView(
                        updateState: state,
                        style: .olimp,
                        onUpdate: {
                            // SDK предоставляет удобный метод для открытия App Store
                            Releazio.shared.openAppStore(updateState: state)
                            showingUpdatePromptOlimp = false
                        },
                        onSkip: { remaining in
                            print("Skipped, remaining: \(remaining)")
                            showingUpdatePromptOlimp = false
                        },
                        onClose: {
                            showingUpdatePromptOlimp = false
                        },
                        onInfoTap: {
                            // SDK предоставляет удобный метод для открытия поста
                            Releazio.shared.openPostURL(updateState: state)
                        }
                    )
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                }
            }
            .overlay(
                Group {
                    if isLoading {
                        ZStack {
                            Color.black.opacity(0.3)
                                .ignoresSafeArea()
                            ProgressView()
                                .scaleEffect(1.5)
                        }
                    }
                }
            )
        }
        .onAppear {
            loadCurrentVersion()
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cube.box.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            VStack(spacing: 8) {
                Text("Releazio iOS SDK")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Professional release management for iOS apps")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var quickActionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ActionButton(
                    title: "Check Updates",
                    icon: "arrow.clockwise",
                    color: .blue
                ) {
                    Task {
                        await checkUpdates()
                    }
                }

                ActionButton(
                    title: "Show Changelog",
                    icon: "doc.text.fill",
                    color: .purple
                ) {
                    Task {
                        await loadRealChangelog()
                    }
                }
                
                if let state = updateState {
                    if state.shouldShowPopup {
                        ActionButton(
                            title: "Show Native Alert",
                            icon: "app.badge.fill",
                            color: .green
                        ) {
                            showingUpdatePromptNative = true
                        }
                        
                        ActionButton(
                            title: "Show Olimp Style",
                            icon: "paintbrush.fill",
                            color: .orange
                        ) {
                            showingUpdatePromptOlimp = true
                        }
                    }
                }
                
                ActionButton(
                    title: isDarkMode ? "Switch to Light" : "Switch to Dark",
                    icon: isDarkMode ? "sun.max.fill" : "moon.fill",
                    color: .purple
                ) {
                    isDarkMode.toggle()
                }
            }
        }
    }
    
    // Version Component внизу экрана
    private var bottomVersionView: some View {
        VStack(spacing: 0) {
            if let state = updateState {
                VersionView(
                    updateState: state,
                    onUpdateTap: {
                        // SDK предоставляет удобный метод для открытия App Store
                        // В примере это будет открывать реальный App Store URL (если приложение есть в сторе)
                        // или показывать ошибку (если приложения нет)
                        Releazio.shared.openAppStore(updateState: state)
                    }
                )
            } else {
                // Show current version from bundle
                let currentVersion = getCurrentVersion()
                VersionView(
                    version: currentVersion,
                    isUpdateAvailable: false
                )
            }
        }
    }

    private func updateStatusView(_ state: UpdateState) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Update Status")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                StatusRow(
                    icon: state.isUpdateAvailable ? "arrow.up.circle.fill" : "checkmark.circle.fill",
                    color: state.isUpdateAvailable ? .orange : .green,
                    title: state.isUpdateAvailable ? "Update Available" : "Up to Date",
                    subtitle: "Current: \(state.currentVersionName) (\(state.currentVersion)) → Latest: \(state.latestVersionName) (\(state.latestVersion))"
                )
                
                if state.shouldShowBadge {
                    StatusRow(
                        icon: "circlebadge.fill",
                        color: .yellow,
                        title: "Badge",
                        subtitle: "New post available"
                    )
                }
                
                if state.shouldShowPopup {
                    StatusRow(
                        icon: "exclamationmark.triangle.fill",
                        color: .red,
                        title: "Popup",
                        subtitle: "Type \(state.updateType) - should show popup"
                    )
                }
                
                if state.shouldShowUpdateButton {
                    StatusRow(
                        icon: "arrow.down.circle.fill",
                        color: .blue,
                        title: "Update Button",
                        subtitle: "Type \(state.updateType) - show update button"
                    )
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    // MARK: - Actions

    private func getCurrentVersion() -> String {
        // Get version name for display (e.g., "1.2.3")
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private func loadCurrentVersion() {
        // Initialize with current version
        let currentVersion = getCurrentVersion()
        print("📱 Current version from bundle: \(currentVersion)")
    }
    
    @MainActor
    private func checkUpdates() async {
        isLoading = true
        
        do {
            let state = try await Releazio.shared.checkUpdates()
            self.updateState = state
            
            print("✅ Update check completed")
            print("   Current: \(state.currentVersion)")
            print("   Latest: \(state.latestVersion)")
            print("   Available: \(state.isUpdateAvailable)")
            print("   Type: \(state.updateType)")
            print("   Show Badge: \(state.shouldShowBadge)")
            print("   Show Popup: \(state.shouldShowPopup)")
            print("   Show Button: \(state.shouldShowUpdateButton)")
            
            isLoading = false
        } catch {
            isLoading = false
            print("❌ Error checking updates: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    private func loadRealChangelog() async {
        isLoading = true
        
        do {
            let config = try await Releazio.shared.getConfig()
            if let postUrl = config.data.first?.postUrl {
                print("🔗 Found post URL: \(postUrl)")
                
                let realChangelog = Changelog(
                    id: "real-changelog",
                    releaseId: "real-release",
                    title: "Version \(config.data.first?.appVersionName ?? "Unknown")",
                    content: postUrl,
                    entries: [],
                    author: Author(name: "Releazio Team", role: "iOS Developers")
                )
                
                self.changelog = realChangelog
                self.showingChangelog = true
                isLoading = false
            } else {
                isLoading = false
                print("⚠️ No post URL found in config")
            }
        } catch {
            isLoading = false
            print("❌ Error loading changelog: \(error.localizedDescription)")
        }
    }
}

// MARK: - Helper Views

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        colorScheme == .light ? Color(.systemGray4) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatusRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 18))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
