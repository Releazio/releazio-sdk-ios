//
//  ReleazioExampleApp.swift
//  ReleazioExample
//
//  Created by Releazio Team on 05.10.2025.
//

import SwiftUI
import Releazio

@main
struct ReleazioExampleApp: App {

    // MARK: - App Lifecycle

    init() {
        // Configure SDK as early as possible
        configureReleazioSDK()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    // MARK: - Private Methods

    private func configureReleazioSDK() {
        let apiKey = "ngqOJgnrvwFqSvVyqUOhxCvnRHisKkoiuI/PycYjiGc="

        // Create configuration
        let configuration = ReleazioConfiguration(
            apiKey: apiKey,
            debugLoggingEnabled: true,
            networkTimeout: 30,
            analyticsEnabled: true,
            cacheExpirationTime: 3600,
            locale: "ru"
        )

        // Configure SDK
        Releazio.configure(with: configuration)

        print("✅ Releazio SDK configured successfully")
        print("🔑 API Key: \(apiKey.prefix(10))...")
    }
}

// MARK: - App Extension for Deep Linking

extension ReleazioExampleApp {

    /// Handle deep links for update notifications
    /// - Parameter url: Deep link URL
    func handleDeepLink(_ url: URL) {
        guard url.scheme == "releazio-example" else { return }

        switch url.host {
        case "update":
            // Navigate to update screen
            NotificationCenter.default.post(
                name: .showUpdatePrompt,
                object: nil
            )
        case "changelog":
            // Navigate to changelog
            NotificationCenter.default.post(
                name: .showChangelog,
                object: nil
            )
        default:
            break
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let showUpdatePrompt = Notification.Name("showUpdatePrompt")
    static let showChangelog = Notification.Name("showChangelog")
}
