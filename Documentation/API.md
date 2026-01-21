# Releazio iOS SDK API Reference

Complete API reference for Releazio iOS SDK integrators.

## Table of Contents

- [Core SDK](#core-sdk)
- [Configuration](#configuration)
- [Update Management](#update-management)
- [Models](#models)
- [UI Components](#ui-components)
- [Localization](#localization)
- [Error Handling](#error-handling)

## Core SDK

### Releazio

The main entry point for the Releazio SDK.

#### Properties

```swift
public class Releazio {
    /// Shared singleton instance of Releazio SDK
    public static let shared: Releazio
}
```

#### Methods

##### `configure(with:)`

Configure the SDK with your API key and settings.

```swift
public static func configure(with configuration: ReleazioConfiguration)
```

**Parameters:**
- `configuration`: `ReleazioConfiguration` object with API key and settings

**Note:** This method automatically calls `init()` in the background to send device information to the server for API request statistics. This includes device ID, screen dimensions, timezone, OS version, and other device-specific data. Errors during `init()` are logged (if `debugLoggingEnabled` is `true`) but do not interrupt the SDK initialization process.

**Example:**
```swift
let config = ReleazioConfiguration(
    apiKey: "your-api-key",
    locale: "en",
    debugLoggingEnabled: true
)
Releazio.configure(with: config)
// Device info is automatically sent to server in the background
```

##### `checkUpdates()`

Main method for checking updates. Returns complete update state information.

```swift
public func checkUpdates() async throws -> UpdateState
```

**Returns:**
- `UpdateState` — Complete state information about updates

**Throws:**
- `ReleazioError.configurationMissing` — If SDK is not configured
- `ReleazioError.networkError` — If network request fails
- `ReleazioError.apiError` — If API returns an error

**Example:**
```swift
Task {
    do {
        let updateState = try await Releazio.shared.checkUpdates()
        
        if updateState.shouldShowPopup {
            // Show popup
        }
        
        if updateState.shouldShowBadge {
            // Show badge
        }
        
        if updateState.shouldShowUpdateButton {
            // Show update button
        }
    } catch {
        print("Error: \(error)")
    }
}
```

##### `openAppStore(updateState:)`

Open App Store for app update.

```swift
public func openAppStore(updateState: UpdateState) -> Bool
```

**Parameters:**
- `updateState`: `UpdateState` object containing update URL

**Returns:**
- `Bool` — `true` if URL was opened successfully, `false` otherwise

**Example:**
```swift
let success = Releazio.shared.openAppStore(updateState: updateState)
if !success {
    print("Failed to open App Store")
}
```

##### `openPostURL(updateState:)`

Open post URL (for badge click or info button).

```swift
public func openPostURL(updateState: UpdateState) -> Bool
```

**Parameters:**
- `updateState`: `UpdateState` object containing post URL

**Returns:**
- `Bool` — `true` if URL was opened successfully, `false` otherwise

**Note:** Automatically marks post as opened for `updateType == 0`.

**Example:**
```swift
let success = Releazio.shared.openPostURL(updateState: updateState)
```

##### `markPostAsOpened(postURL:)`

Mark a post as opened (hides badge for `updateType == 0`).

```swift
public func markPostAsOpened(postURL: String)
```

**Parameters:**
- `postURL`: Post URL string

**Example:**
```swift
Releazio.shared.markPostAsOpened(postURL: "https://releazio.com/post/123")
```

##### `markPopupAsShown(version:updateType:)`

Mark popup as shown (for tracking `show_interval` logic).

```swift
public func markPopupAsShown(version: String, updateType: Int)
```

**Parameters:**
- `version`: Version identifier
- `updateType`: Update type (2 or 3)

**Example:**
```swift
Releazio.shared.markPopupAsShown(
    version: updateState.currentVersion,
    updateType: updateState.updateType
)
```

##### `skipUpdate(version:)`

Skip an update and decrement skip attempts (for `updateType == 3`).

```swift
public func skipUpdate(version: String) -> Int
```

**Parameters:**
- `version`: Version identifier

**Returns:**
- `Int` — Remaining skip attempts after decrement

**Example:**
```swift
let remaining = Releazio.shared.skipUpdate(version: updateState.currentVersion)
print("Remaining skips: \(remaining)")

if remaining == 0 {
    // No skips left, close popup
}
```

##### `getConfig()`

Get configuration from API directly.

```swift
public func getConfig() async throws -> ConfigResponse
```

**Returns:**
- `ConfigResponse` — Full configuration response from API

**Example:**
```swift
Task {
    do {
        let config = try await Releazio.shared.getConfig()
        let channelData = config.data.first
        print("Latest version: \(channelData?.appVersionName ?? "unknown")")
    } catch {
        print("Error: \(error)")
    }
}
```

##### `getConfiguration()`

Get current SDK configuration.

```swift
public func getConfiguration() -> ReleazioConfiguration?
```

**Returns:**
- `ReleazioConfiguration?` — Current configuration or `nil` if not configured

##### `reset()`

Reset SDK configuration and clear cached data.

```swift
public func reset()
```

#### Deprecated Methods

##### `checkForUpdates()` ⚠️ Deprecated

**Deprecated:** Use `checkUpdates()` instead.

```swift
@available(*, deprecated)
public func checkForUpdates() async throws -> Bool
```

This method only returns a boolean and doesn't provide full update state information. Use `checkUpdates()` for complete update state.

##### `getReleases()` ⚠️ Deprecated

**Deprecated:** Use `checkUpdates()` to get update state with full channel data.

```swift
@available(*, deprecated)
public func getReleases() async throws -> [Release]
```

##### `getLatestRelease()` ⚠️ Deprecated

**Deprecated:** Use `checkUpdates()` instead.

```swift
@available(*, deprecated)
public func getLatestRelease() async throws -> Release?
```

This method doesn't provide update type and state information needed for proper update handling.

##### `showUpdatePrompt()` ⚠️ Deprecated

**Deprecated:** Not implemented. Use UI components directly.

```swift
@available(*, deprecated)
public func showUpdatePrompt()
```

This method is not implemented. Use `ReleazioUpdatePromptView` (SwiftUI) or `ReleazioUpdatePromptViewController` (UIKit) directly to show update prompts.

**Note:** For backward compatibility, these deprecated methods are still available:
- ~~`checkForUpdates() async throws -> Bool`~~ - **Deprecated**: Use `checkUpdates()` instead
- ~~`getReleases() async throws -> [Release]`~~ - **Deprecated**: Use `checkUpdates()` to get update state with full channel data
- ~~`getLatestRelease() async throws -> Release?`~~ - **Deprecated**: Use `checkUpdates()` instead
- `getChangelog(for:) async throws -> Changelog` - Available for specific use cases

## Configuration

### ReleazioConfiguration

Configuration object for SDK initialization.

```swift
public struct ReleazioConfiguration {
    public let apiKey: String
    public let debugLoggingEnabled: Bool
    public let networkTimeout: TimeInterval
    public let analyticsEnabled: Bool
    public let cacheExpirationTime: TimeInterval
    public let locale: String
    #if canImport(UIKit)
    public let badgeColor: UIColor?
    #else
    public let badgeColor: Any?
    #endif
    
    public init(
        apiKey: String,
        debugLoggingEnabled: Bool = false,
        networkTimeout: TimeInterval = 30,
        analyticsEnabled: Bool = true,
        cacheExpirationTime: TimeInterval = 3600,
        locale: String = "en",
        badgeColor: UIColor? = nil
    )
}
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `apiKey` | `String` | **Required** | Your Releazio API key |
| `debugLoggingEnabled` | `Bool` | `false` | Enable debug logging |
| `networkTimeout` | `TimeInterval` | `30` | Network request timeout in seconds |
| `analyticsEnabled` | `Bool` | `true` | Enable analytics tracking |
| `cacheExpirationTime` | `TimeInterval` | `3600` | Cache expiration time in seconds (1 hour) |
| `locale` | `String` | `"en"` | Locale identifier (`"en"` or `"ru"`) |
| `badgeColor` | `UIColor?` | `nil` | Custom badge color (default: system yellow) |

#### Example

```swift
let configuration = ReleazioConfiguration(
    apiKey: "your-api-key",
    locale: "ru",
    debugLoggingEnabled: true,
    badgeColor: UIColor.systemOrange
)
Releazio.configure(with: configuration)
```

## Update Management

### UpdateState

Complete state information returned by `checkUpdates()`.

```swift
public struct UpdateState {
    /// Update type from API (0, 1, 2, 3)
    public let updateType: Int
    
    /// Whether badge should be shown (for type 0)
    public let shouldShowBadge: Bool
    
    /// Whether popup should be shown (for types 2, 3)
    public let shouldShowPopup: Bool
    
    /// Whether update button should be shown (for type 1)
    public let shouldShowUpdateButton: Bool
    
    /// Remaining skip attempts (for type 3)
    public let remainingSkipAttempts: Int
    
    /// Full channel data from API
    public let channelData: ChannelData
    
    /// URL to open when badge is clicked (post_url or posts_url)
    public let badgeURL: String?
    
    /// URL for app update (app_url or app_deeplink)
    public let updateURL: String?
    
    /// Current app version code (for comparison)
    public let currentVersion: String
    
    /// Latest available version code from API
    public let latestVersion: String
    
    /// Current app version name (for display, e.g., "1.2.3")
    public let currentVersionName: String
    
    /// Latest available version name from API (e.g., "2.5.1")
    public let latestVersionName: String
    
    /// Whether update is available (version comparison)
    public let isUpdateAvailable: Bool
}
```

### Update Types

SDK supports 4 update types:

| Type | Name | Description | Behavior |
|------|------|-------------|----------|
| `0` | `latest` | Latest available | Show badge only, open post_url on click |
| `1` | `silent` | Silent update | Show update button only, no popup |
| `2` | `popup` | Popup update | Show closable popup with show_interval logic |
| `3` | `popup force` | Force popup | Show non-closable popup with skip_attempts |

## Models

### ConfigResponse

Response from `getConfig` API endpoint.

```swift
public struct ConfigResponse: Codable {
    /// Home URL for the application
    public let homeUrl: String
    
    /// Array of channel data
    public let data: [ChannelData]
}
```

### ChannelData

Channel-specific update information.

```swift
public struct ChannelData: Codable {
    /// Channel type (e.g., "appstore")
    public let channel: String
    
    /// App version code (build number)
    public let appVersionCode: String
    
    /// App version name (display version, e.g., "2.5.1")
    public let appVersionName: String
    
    /// App deep link URL (itms-apps://...)
    public let appDeeplink: String?
    
    /// Channel package name (null for iOS)
    public let channelPackageName: String?
    
    /// App store URL (https://apps.apple.com/...)
    public let appUrl: String?
    
    /// Post URL (single post)
    public let postUrl: String?
    
    /// Posts URL (all posts)
    public let postsUrl: String?
    
    /// Update type (0, 1, 2, 3)
    public let updateType: Int
    
    /// Update message
    public let updateMessage: String
    
    /// Skip attempts count (for type 3)
    public let skipAttempts: Int
    
    /// Show interval in minutes (for type 2, 3)
    public let showInterval: Int
    
    // Computed properties
    public var hasUpdate: Bool
    public var isLatest: Bool      // updateType == 0
    public var isSilent: Bool      // updateType == 1
    public var isPopup: Bool       // updateType == 2
    public var isPopupForce: Bool  // updateType == 3
    public var isMandatory: Bool   // updateType == 2 || 3
    public var isOptional: Bool    // updateType == 0 || 1
    public var primaryDownloadUrl: String?  // appUrl ?? appDeeplink
}
```

### Changelog

Changelog model (used for displaying posts).

```swift
public struct Changelog: Codable, Identifiable {
    public let id: String
    public let title: String
    public let content: String  // Can be post_url for WebView
    public let releaseId: String
    public let createdAt: Date
}
```

## UI Components

### SwiftUI Components

#### ReleazioUpdatePromptView

Modal popup for update prompts with two styles: Native iOS Alert and InAppUpdate.

```swift
public struct ReleazioUpdatePromptView: View {
    public init(
        updateState: UpdateState,
        style: UpdatePromptStyle = .default,
        customColors: UIComponentColors? = nil,
        customStrings: UILocalizationStrings? = nil,
        onUpdate: (() -> Void)?,
        onSkip: ((Int) -> Void)? = nil,
        onClose: (() -> Void)? = nil,
        onInfoTap: (() -> Void)? = nil
    )
}
```

**Parameters:**
- `updateState`: `UpdateState` from `checkUpdates()`
- `style`: `.native` (default: `.default` which is `.native`)
- `customColors`: Optional custom colors for buttons and text (see `UIComponentColors`)
- `customStrings`: Optional custom localization strings (see `UILocalizationStrings`)
- `onUpdate`: Callback when user taps "Update" button
- `onSkip`: Callback when user skips (only for `updateType == 3`)
- `onClose`: Callback when user closes popup (only for `updateType == 2`)
- `onInfoTap`: Callback when user taps info button (?)

**Note:** Locale is automatically detected from system settings. The SDK supports English ("en") and Russian ("ru"), with fallback to English for other languages. You can provide custom strings for any language using `customStrings`.

**Example:**
```swift
// Basic usage with auto-detected locale
ReleazioUpdatePromptView(
    updateState: updateState,
    style: .native,
    onUpdate: {
        Releazio.shared.openAppStore(updateState: updateState)
    }
)

// With custom colors and strings
let customColors = UIComponentColors(
    updateButtonColor: .blue,
    updateButtonTextColor: .white
)

let customStrings = UILocalizationStrings(
    updateTitle: "Custom Update Title",
    updateMessage: "Custom update message",
    updateButtonText: "Update Now"
)

ReleazioUpdatePromptView(
    updateState: updateState,
    style: .native,
    customColors: customColors,
    customStrings: customStrings,
    onUpdate: {
        Releazio.shared.openAppStore(updateState: updateState)
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

```swift
public struct VersionView: View {
    public init(
        updateState: UpdateState,
        customColors: UIComponentColors? = nil,
        customStrings: UILocalizationStrings? = nil,
        onUpdateTap: (() -> Void)? = nil,
        onVersionTap: (() -> Void)? = nil
    )
    
    // Or initialize with individual parameters
    public init(
        version: String,
        isUpdateAvailable: Bool = false,
        customColors: UIComponentColors? = nil,
        customStrings: UILocalizationStrings? = nil,
        onUpdateTap: (() -> Void)? = nil,
        onVersionTap: (() -> Void)? = nil
    )
}
```

**Parameters:**
- `updateState` or `version`/`isUpdateAvailable`: Version information
- `customColors`: Optional custom colors (supports `updateButtonColor`, `updateButtonTextColor`, `versionBackgroundColor`, `versionTextColor`)
- `customStrings`: Optional custom strings (supports `versionText`, `updateButtonText`)
- `onUpdateTap`: Callback when update button is tapped
- `onVersionTap`: Optional callback when version text is tapped (default: opens badgeURL)

**Note:** Locale is automatically detected from system settings.

**Example:**
```swift
// Basic usage
VersionView(
    updateState: updateState,
    onUpdateTap: {
        Releazio.shared.openAppStore(updateState: updateState)
    }
)

// With custom colors
let customColors = UIComponentColors(
    updateButtonColor: Color(red: 0.2, green: 0.6, blue: 1.0),
    updateButtonTextColor: .white
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

Badge component for indicating new updates.

```swift
public struct BadgeView: View {
    public init(
        text: String,
        backgroundColor: Color = .yellow,
        textColor: Color = .black,
        font: Font = .caption.bold(),
        padding: EdgeInsets = EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8),
        cornerRadius: CGFloat = 8
    )
}
```

**Example:**
```swift
if updateState.shouldShowBadge {
    BadgeView(
        text: "New",
        backgroundColor: .yellow,
        textColor: .black
    )
}
```

#### ChangelogView

View for displaying changelog with WebView support.

```swift
public struct ChangelogView: View {
    @State public var changelog: Changelog
    
    public init(changelog: Changelog, onDismiss: (() -> Void)? = nil)
}
```

**Note:** If `changelog.content` contains a URL, it will be opened in WebView.

**Example:**
```swift
ChangelogView(changelog: changelog) {
    // Dismiss handler
}
```

### UIKit Components

#### ReleazioUpdatePromptViewController

ViewController for update prompts.

```swift
public class ReleazioUpdatePromptViewController: UIViewController {
    public init(
        updateState: UpdateState,
        customColors: UIComponentColors? = nil,
        customStrings: UILocalizationStrings? = nil,
        onUpdate: (() -> Void)? = nil,
        onSkip: ((Int) -> Void)? = nil,
        onClose: (() -> Void)? = nil,
        onInfoTap: (() -> Void)? = nil
    )
}
```

**Note:** Locale is automatically detected from system settings.

**Example:**
```swift
let viewController = ReleazioUpdatePromptViewController(
    updateState: updateState,
    onUpdate: {
        Releazio.shared.openAppStore(updateState: updateState)
    },
    onSkip: { remaining in
        print("Remaining: \(remaining)")
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

UIKit view for displaying version with update button.

```swift
public class VersionUIKitView: UIView {
    public init(
        updateState: UpdateState,
        customColors: UIComponentColors? = nil,
        customStrings: UILocalizationStrings? = nil,
        frame: CGRect = .zero
    )
    
    public var onUpdateTap: (() -> Void)?
}
```

**Note:** Locale is automatically detected from system settings.

**Example:**
```swift
let versionView = VersionUIKitView(
    updateState: updateState
)
versionView.onUpdateTap = {
    Releazio.shared.openAppStore(updateState: updateState)
}
view.addSubview(versionView)
// Setup constraints
```

#### ChangelogViewController

ViewController for displaying changelog.

```swift
public class ChangelogViewController: UIViewController {
    public init(changelog: Changelog)
}
```

## Localization

The SDK automatically detects the system locale and supports two built-in languages:
- `"en"` — English (fallback)
- `"ru"` — Russian

For other languages, the SDK falls back to English. You can provide custom localized strings for any language using `UILocalizationStrings`.

### Automatic Locale Detection

Locale is automatically detected from `Locale.current.languageCode`. You don't need to pass `locale` parameter to UI components anymore.

### UIComponentColors

Custom color configuration for UI components.

```swift
public struct UIComponentColors {
    public let updateButtonColor: Color?          // Update button background
    public let updateButtonTextColor: Color?      // Update button text
    public let skipButtonColor: Color?            // Skip button background
    public let skipButtonTextColor: Color?        // Skip button text
    public let closeButtonColor: Color?           // Close button color
    public let linkColor: Color?                  // Link color (for "What's New")
    public let badgeColor: Color?                 // Badge background
    public let badgeTextColor: Color?             // Badge text
    public let versionBackgroundColor: Color?      // Version label background
    public let versionTextColor: Color?           // Version label text
    public let primaryTextColor: Color?           // Primary text (titles, messages)
    public let secondaryTextColor: Color?         // Secondary text (subtitles)
    
    public init(
        updateButtonColor: Color? = nil,
        updateButtonTextColor: Color? = nil,
        // ... other colors
    )
}
```

**Note:** For UIKit, use `UIColor` instead of `Color`.

**Example:**
```swift
let customColors = UIComponentColors(
    updateButtonColor: .blue,
    updateButtonTextColor: .white,
    linkColor: .systemBlue
)
```

### UILocalizationStrings

Custom localization strings for UI components. All strings are optional - if `nil`, default SDK strings will be used.

```swift
public struct UILocalizationStrings {
    public let updateTitle: String?                // Update prompt title
    public let updateMessage: String?              // Update message
    public let updateButtonText: String?           // "Update" button text
    public let skipButtonText: String?             // "Skip" button text
    public let closeButtonText: String?            // "Close" button text
    public let badgeNewText: String?              // Badge "New" text
    public let whatsNewText: String?              // "What's New" link text
    public let versionText: String?                // Version label text
    public let skipRemainingTextFormat: String?    // Skip attempts format (use "%d" for number)
    
    public init(
        updateTitle: String? = nil,
        updateMessage: String? = nil,
        // ... other strings
    )
}
```

**Example:**
```swift
let customStrings = UILocalizationStrings(
    updateTitle: "Update Available",
    updateButtonText: "Update Now",
    skipRemainingTextFormat: "You can skip %d more times"
)
```

### LocalizationManager

Helper class for accessing localized strings (internal use). Includes static method for detecting system locale:

```swift
public static func detectSystemLocale() -> String
```

Returns `"ru"` if system language is Russian, otherwise `"en"`.

## Error Handling

### ReleazioError

Custom error types for the SDK.

```swift
public enum ReleazioError: Error, LocalizedError, Equatable {
    // Configuration Errors
    case configurationMissing
    case invalidApiKey
    case invalidConfiguration(String)
    
    // Network Errors
    case networkError(Error)
    case invalidURL(String)
    case requestTimeout
    case noInternetConnection
    case serverError(statusCode: Int, message: String?)
    
    // API Response Errors
    case invalidResponse
    case apiError(code: String, message: String?)
    case missingData(String)
    case decodingError(Error)
    
    // Validation Errors
    case invalidVersionFormat(String)
    case versionComparisonError
}
```

### Error Handling Example

```swift
Task {
    do {
        let updateState = try await Releazio.shared.checkUpdates()
        // Handle success
    } catch ReleazioError.configurationMissing {
        print("SDK not configured")
    } catch ReleazioError.networkError(let error) {
        print("Network error: \(error)")
    } catch ReleazioError.apiError(let code, let message) {
        print("API error [\(code)]: \(message ?? "Unknown")")
    } catch {
        print("Unknown error: \(error)")
    }
}
```

---

For integration examples, see the [Integration Guide](Integration.md).
