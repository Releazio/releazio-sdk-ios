# Releazio iOS SDK

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Language / Язык:** [English](#) | [Русский](./README.ru.md)

**Releazio iOS SDK** — a modern library for managing application updates in iOS. The SDK provides a complete set of tools for checking updates, displaying changelog, and managing various types of updates.

## ✨ Key Features

- 🚀 **Update Checking** — Automatic checking for new versions via API
- 🎯 **4 Update Types** — Support for latest, silent, popup, and popup force modes
- 📝 **Changelog** — Display changes with WebView support for posts
- 🎨 **UI Components** — Ready-made components for SwiftUI and UIKit
- 🌍 **Localization** — Support for English and Russian languages
- 🔔 **Badges and Notifications** — Indicators for new versions
- ⚙️ **Flexible Configuration** — Customization of colors, locale, and behavior

## 📋 Requirements

- iOS 15.0+ / macOS 12.0+ / watchOS 8.0+ / tvOS 15.0+
- Swift 5.9+
- Xcode 14.0+

## 📦 Installation

### Swift Package Manager

**Add to Xcode:**
1. File → Add Package Dependencies
2. Paste URL: `https://github.com/Releazio/releazio-sdk-ios`
3. Select version and add to project

**Or in Package.swift:**
```swift
dependencies: [
    .package(url: "https://github.com/Releazio/releazio-sdk-ios", from: "1.0.5")
]
```

> **Note:** Using `from: "1.0.5"` means minimum version 1.0.5, while automatically picking up the latest available version in the 1.x.x range (up to the next major version 2.0.0). When updating dependencies in Xcode, the latest version (1.0.6, 1.2.0, 1.5.0, etc.) will be used. You don't need to update the version in README with each release.

<!-- CocoaPods installation is not supported; use Swift Package Manager -->

## 🚀 Quick Start

### 1. Import SDK

```swift
import Releazio
```

### 2. Configure SDK

```swift
@main
struct YourApp: App {
    init() {
        let configuration = ReleazioConfiguration(
            apiKey: "your-api-key",
            locale: "en", // or "ru"
            debugLoggingEnabled: true
        )
        
        Releazio.configure(with: configuration)
        // Note: configure() automatically calls init() in the background
        // to send device info (screen dimensions, timezone, device ID, etc.)
        // to the server for API request statistics.
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 3. Check Updates

```swift
Task {
    do {
        let updateState = try await Releazio.shared.checkUpdates()
        
        // Check if popup should be shown
        if updateState.shouldShowPopup {
            // Show ReleazioUpdatePromptView
        }
        
        // Check if badge should be shown
        if updateState.shouldShowBadge {
            // Show BadgeView
        }
        
        // Check if update button should be shown
        if updateState.shouldShowUpdateButton {
            // Show update button
        }
    } catch {
        print("Update check error: \(error)")
    }
}
```

## 📚 Update Types

The SDK supports 4 update types according to the API:

- **Type 0 (latest)** — Badge is shown, clicking opens post_url
- **Type 1 (silent)** — Only "Update" button, popup is not shown
- **Type 2 (popup)** — Closable popup with show_interval support
- **Type 3 (popup force)** — Non-closable popup with limited skip attempts (skip_attempts)

## 🎨 UI Components

### SwiftUI

#### ReleazioUpdatePromptView
Update popup with support for two styles: Native iOS Alert and InAppUpdate.

```swift
ReleazioUpdatePromptView(
    updateState: updateState,
    onUpdate: {
        Releazio.shared.openAppStore(updateState: updateState)
    },
    onSkip: { remaining in
        print("Remaining skips: \(remaining)")
    },
    onClose: {
        // Close popup
    },
    onInfoTap: {
        Releazio.shared.openPostURL(updateState: updateState)
    }
)
```

#### VersionView
Component for displaying app version with update button (Type 1 - bottom of screen component).

This component displays:
- Version text (e.g., "Version 1.2") with optional yellow dot indicator when post is unread
- Update button (black by default) when update is available

**Features:**
- Yellow dot appears when there's an unread post (postUrl exists and hasn't been opened)
- Tapping version text opens post URL (post_url if available, otherwise posts_url)
- Update button opens App Store URL (app_url)
- Fully customizable colors and strings

**SwiftUI Example:**
```swift
VersionView(
    updateState: updateState,
    onUpdateTap: {
        Releazio.shared.openAppStore(updateState: updateState)
    },
    onVersionTap: {
        // Optional: custom handler for version tap
        // Default: opens badgeURL (post_url or posts_url)
        Releazio.shared.openPostURL(updateState: updateState)
    }
)
```

**With custom colors:**
```swift
let customColors = UIComponentColors(
    updateButtonColor: .black,
    updateButtonTextColor: .white,
    versionBackgroundColor: .systemGray6,
    versionTextColor: .label
)

VersionView(
    updateState: updateState,
    customColors: customColors,
    onUpdateTap: {
        Releazio.shared.openAppStore(updateState: updateState)
    }
)
```

#### BadgeView
Badge indicator for new updates.

```swift
BadgeView(
    text: localization.badgeNewText,
    backgroundColor: .yellow,
    textColor: .black
)
```

#### ChangelogView
Display changelog with WebView support for loading posts.

```swift
ChangelogView(changelog: changelog)
```

### UIKit

#### ReleazioUpdatePromptViewController

```swift
let viewController = ReleazioUpdatePromptViewController(
    updateState: updateState,
    onUpdate: {
        Releazio.shared.openAppStore(updateState: updateState)
    },
    onSkip: { remaining in
        print("Remaining skips: \(remaining)")
    },
    onClose: {
        self.dismiss(animated: true)
    },
    onInfoTap: {
        Releazio.shared.openPostURL(updateState: updateState)
    }
)

present(viewController, animated: true)
```

#### VersionUIKitView
UIKit component for displaying app version with update button (Type 1 - bottom of screen component).

**Features:**
- Yellow dot indicator when post is unread
- Tappable version label opens post URL
- Black update button by default
- Fully customizable

```swift
let versionView = VersionUIKitView(
    updateState: updateState
)

versionView.onUpdateTap = {
    Releazio.shared.openAppStore(updateState: updateState)
}

versionView.onVersionTap = {
    // Optional: custom handler for version tap
    // Default: opens badgeURL (post_url or posts_url)
    Releazio.shared.openPostURL(updateState: updateState)
}

view.addSubview(versionView)
// Setup constraints
```

#### ChangelogViewController

```swift
let changelogVC = ChangelogViewController(changelog: changelog)
present(changelogVC, animated: true)
```

## 🔧 API Reference

### Main Methods

#### `checkUpdates() async throws -> UpdateState`
Main method for checking updates. Returns `UpdateState` with complete information about update status.

```swift
let updateState = try await Releazio.shared.checkUpdates()
```

#### `openAppStore(updateState:) -> Bool`
Opens App Store for app update.

```swift
Releazio.shared.openAppStore(updateState: updateState)
```

#### `openPostURL(updateState:) -> Bool`
Opens post URL (for type 0 or when clicking info button).

```swift
Releazio.shared.openPostURL(updateState: updateState)
```

#### `markPostAsOpened(postURL:)`
Marks post as opened (for type 0, to hide badge).

```swift
Releazio.shared.markPostAsOpened(postURL: postURL)
```

#### `markPopupAsShown(version:updateType:)`
Marks popup as shown (for type 2, 3).

```swift
Releazio.shared.markPopupAsShown(
    version: updateState.currentVersion,
    updateType: updateState.updateType
)
```

#### `skipUpdate(version:) -> Int`
Skips update and returns remaining attempts count (for type 3).

```swift
let remaining = Releazio.shared.skipUpdate(version: updateState.currentVersion)
```

### UpdateState

Structure returned by `checkUpdates()` method contains:

- `updateType: Int` — Update type (0, 1, 2, 3)
- `shouldShowBadge: Bool` — Whether to show badge (type 0)
- `shouldShowPopup: Bool` — Whether to show popup (type 2, 3)
- `shouldShowUpdateButton: Bool` — Whether to show update button (type 1)
- `remainingSkipAttempts: Int` — Remaining skips (type 3)
- `channelData: ChannelData` — Full data from API
- `badgeURL: String?` — URL to open when badge is clicked
- `updateURL: String?` — URL for app update
- `currentVersionName: String` — Current app version (for display)
- `latestVersionName: String` — Latest available version (for display)
- `isUpdateAvailable: Bool` — Whether update is available

## ⚙️ Configuration

### ReleazioConfiguration

```swift
let configuration = ReleazioConfiguration(
    apiKey: "your-api-key",                      // Required
    debugLoggingEnabled: false,                   // Default: false
    networkTimeout: 30,                          // Default: 30 seconds
    analyticsEnabled: true,                       // Default: true
    cacheExpirationTime: 3600,                    // Default: 3600 seconds (1 hour)
    locale: "en",                                 // Default: "en" (supports "ru")
    badgeColor: UIColor.systemYellow              // Default: nil (system yellow)
)
```

### Parameters

- **apiKey** — API key for authentication (required)
- **debugLoggingEnabled** — Enable debug logging
- **networkTimeout** — Network request timeout in seconds
- **analyticsEnabled** — Enable analytics collection
- **cacheExpirationTime** — Cache lifetime in seconds
- **locale** — Locale for localization ("en" or "ru")
- **badgeColor** — Custom badge color (optional)

## 🌍 Localization

The SDK supports two languages:

- **en** — English
- **ru** — Russian

Localized strings:
- `update.title` — Update popup title
- `update.message` — Update message
- `update.button.update` — "Update" button text
- `update.button.skip` — "Skip" button text
- `update.button.close` — "Close" button text
- `update.badge.new` — Badge "New" text
- `update.whats.new` — "What's New" text

## 📖 Documentation

Detailed documentation is available in the following files:

- **[API Documentation](./Documentation/API.md)** — Complete API reference
- **[Integration Guide](./Documentation/Integration.md)** — Integration guide

To generate documentation use:

```bash
jazzy --source-directory Sources/Releazio
```

## 💡 Usage Examples

Full integration example is available in the [Examples](./Examples/ReleazioExample/) folder.

### Full Integration Example (SwiftUI)

```swift
import SwiftUI
import Releazio

struct ContentView: View {
    @State private var updateState: UpdateState?
    @State private var showUpdatePrompt = false
    
    var body: some View {
        VStack {
            // Your content
            
            // Version and update button
            if let updateState = updateState {
                VersionView(
                    updateState: updateState,
                    locale: "en",
                    onUpdateTap: {
                        Releazio.shared.openAppStore(updateState: updateState)
                    }
                )
            }
        }
        .onAppear {
            checkUpdates()
        }
        .sheet(isPresented: $showUpdatePrompt) {
            if let updateState = updateState {
                ReleazioUpdatePromptView(
                    updateState: updateState,
                    style: .native,
                    locale: "en",
                    onUpdate: {
                        Releazio.shared.openAppStore(updateState: updateState)
                    },
                    onSkip: { remaining in
                        Releazio.shared.skipUpdate(version: updateState.currentVersion)
                        if remaining == 0 {
                            showUpdatePrompt = false
                        }
                    },
                    onClose: {
                        Releazio.shared.markPopupAsShown(
                            version: updateState.currentVersion,
                            updateType: updateState.updateType
                        )
                        showUpdatePrompt = false
                    },
                    onInfoTap: {
                        Releazio.shared.openPostURL(updateState: updateState)
                    }
                )
            }
        }
    }
    
    private func checkUpdates() {
        Task {
            do {
                let state = try await Releazio.shared.checkUpdates()
                await MainActor.run {
                    updateState = state
                    
                    // Show popup if needed
                    if state.shouldShowPopup {
                        showUpdatePrompt = true
                    }
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
}
```

## 🐛 Error Handling

The SDK uses `ReleazioError` for error handling:

```swift
do {
    let updateState = try await Releazio.shared.checkUpdates()
} catch ReleazioError.configurationMissing {
    print("SDK not configured")
} catch ReleazioError.apiError(let code, let message) {
    print("API error: \(code) - \(message)")
} catch {
    print("Unknown error: \(error)")
}
```

## 🤝 Support

- 📧 Email: support@releazio.com
- 🐛 Issues: [GitHub Issues](https://github.com/Releazio/releazio-sdk-ios/issues)
- 📖 Documentation: [Releazio Docs](https://releazio.com/docs)

## 📄 License

Releazio iOS SDK is available under the MIT license. See [LICENSE](LICENSE) for details.

---

**Made with ❤️ by the Releazio team**
