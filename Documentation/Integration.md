# Releazio iOS SDK Integration Guide

Complete step-by-step guide for integrating Releazio iOS SDK into your application.

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Basic Usage](#basic-usage)
- [Update Types](#update-types)
- [UI Integration](#ui-integration)
- [SwiftUI Integration](#swiftui-integration)
- [UIKit Integration](#uikit-integration)
- [Localization](#localization)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Installation

### Swift Package Manager (Recommended)

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter the repository URL:
   ```
   https://github.com/Releazio/releazio-sdk-ios
   ```
3. Select version range or specific version
4. Add to your app target
5. Click **Add Package**

Alternatively, add to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Releazio/releazio-sdk-ios", from: "1.0.0")
]
```

### Manual Installation

1. Clone the repository
2. Drag `Sources/Releazio` folder into your Xcode project
3. Ensure all files are added to your target
4. Configure build settings

## Quick Start

### 1. Import SDK

```swift
import Releazio
```

### 2. Configure SDK

In your `AppDelegate` or SwiftUI `App`:

```swift
@main
struct YourApp: App {
    init() {
        let configuration = ReleazioConfiguration(
            apiKey: "your-api-key",
            locale: "en",  // or "ru"
            debugLoggingEnabled: true
        )
        
        Releazio.configure(with: configuration)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 3. Check for Updates

```swift
Task {
    do {
        let updateState = try await Releazio.shared.checkUpdates()
        
        // Check what to show
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
        print("Error checking updates: \(error)")
    }
}
```

## Configuration

### Basic Configuration

```swift
let configuration = ReleazioConfiguration(
    apiKey: "your-api-key",
    debugLoggingEnabled: false,
    analyticsEnabled: true,
    locale: "en"
)
```

### Full Configuration Options

```swift
let configuration = ReleazioConfiguration(
    apiKey: "your-api-key",              // Required
    debugLoggingEnabled: false,           // Default: false
    networkTimeout: 30,                  // Default: 30 seconds
    analyticsEnabled: true,               // Default: true
    cacheExpirationTime: 3600,           // Default: 3600 seconds (1 hour)
    locale: "en",                        // Default: "en" (supported: "en", "ru")
    badgeColor: UIColor.systemYellow     // Optional, default: system yellow
)
```

### Environment-Specific Configuration

```swift
#if DEBUG
let configuration = ReleazioConfiguration(
    apiKey: debugApiKey,
    debugLoggingEnabled: true,
    locale: "en"
)
#else
let configuration = ReleazioConfiguration(
    apiKey: productionApiKey,
    debugLoggingEnabled: false,
    locale: "ru"
)
#endif

Releazio.configure(with: configuration)
```

### Configuration Validation

```swift
let configuration = ReleazioConfiguration(apiKey: "your-key")
if configuration.validate() {
    Releazio.configure(with: configuration)
} else {
    print("Invalid configuration")
}
```

## Basic Usage

### Checking Updates

The main method for checking updates is `checkUpdates()`, which returns complete state information:

```swift
Task {
    do {
        let updateState = try await Releazio.shared.checkUpdates()
        
        print("Update type: \(updateState.updateType)")
        print("Current version: \(updateState.currentVersionName)")
        print("Latest version: \(updateState.latestVersionName)")
        print("Update available: \(updateState.isUpdateAvailable)")
        
        // Handle based on update type
        switch updateState.updateType {
        case 0: // latest
            if updateState.shouldShowBadge {
                // Show badge
            }
        case 1: // silent
            if updateState.shouldShowUpdateButton {
                // Show update button
            }
        case 2, 3: // popup, popup force
            if updateState.shouldShowPopup {
                // Show popup
            }
        default:
            break
        }
    } catch {
        print("Error: \(error)")
    }
}
```

### Opening App Store

```swift
let success = Releazio.shared.openAppStore(updateState: updateState)
if success {
    print("App Store opened")
} else {
    print("Failed to open App Store")
}
```

### Opening Post URL

```swift
let success = Releazio.shared.openPostURL(updateState: updateState)
// Automatically marks post as opened for updateType == 0
```

### Manual Post Tracking

For `updateType == 0`, track when user opens post:

```swift
if updateState.updateType == 0 {
    Releazio.shared.markPostAsOpened(postURL: updateState.badgeURL ?? "")
}
```

### Popup Tracking

For `updateType == 2` or `3`, track when popup is shown:

```swift
if updateState.shouldShowPopup {
    // Show popup
    Releazio.shared.markPopupAsShown(
        version: updateState.currentVersion,
        updateType: updateState.updateType
    )
}
```

### Skipping Updates

For `updateType == 3`, handle skip attempts:

```swift
let remaining = Releazio.shared.skipUpdate(version: updateState.currentVersion)

if remaining > 0 {
    print("Remaining skips: \(remaining)")
} else {
    // No skips left, close popup or force update
}
```

## Update Types

SDK supports 4 update types with different behaviors:

### Type 0: Latest (Badge Only)

- Shows badge indicator
- Opens `post_url` when badge is clicked
- Badge hides after post is opened
- No popup or update prompt

**Implementation:**
```swift
if updateState.shouldShowBadge {
    // Show BadgeView
    BadgeView(text: "New")
        .onTapGesture {
            Releazio.shared.openPostURL(updateState: updateState)
        }
}
```

### Type 1: Silent (Update Button Only)

- Shows update button only
- No popup or badge
- Integrator decides where to place button

**Implementation:**
```swift
if updateState.shouldShowUpdateButton {
    Button("Update") {
        Releazio.shared.openAppStore(updateState: updateState)
    }
}
```

### Type 2: Popup (Closable)

- Shows closable popup
- Respects `show_interval` (minutes between shows)
- Can be dismissed by user
- Has close button (X)

**Implementation:**
```swift
if updateState.shouldShowPopup {
    ReleazioUpdatePromptView(
        updateState: updateState,
        style: .native,
        onUpdate: {
            Releazio.shared.openAppStore(updateState: updateState)
        },
        onClose: {
            Releazio.shared.markPopupAsShown(
                version: updateState.currentVersion,
                updateType: updateState.updateType
            )
        }
    )
}
```

### Type 3: Popup Force (Non-Closable with Skip)

- Shows non-closable popup
- Has skip attempts counter
- Can be skipped limited number of times
- No close button (only when skip attempts = 0)

**Implementation:**
```swift
if updateState.shouldShowPopup {
    ReleazioUpdatePromptView(
        updateState: updateState,
        style: .native,
        onUpdate: {
            Releazio.shared.openAppStore(updateState: updateState)
        },
        onSkip: { remaining in
            if remaining > 0 {
                print("Remaining skips: \(remaining)")
            } else {
                // No skips left, close popup
            }
        }
    )
}
```

## UI Integration

### Complete SwiftUI Example

```swift
import SwiftUI
import Releazio

struct ContentView: View {
    @State private var updateState: UpdateState?
    @State private var showUpdatePopup = false
    @State private var showChangelog = false
    
    var body: some View {
        VStack {
            // Your content
            
            // Badge (for type 0)
            if let state = updateState, state.shouldShowBadge {
                BadgeView(text: "New")
                    .onTapGesture {
                        Releazio.shared.openPostURL(updateState: state)
                    }
            }
            
            // Update button (for type 1)
            if let state = updateState, state.shouldShowUpdateButton {
                Button("Update") {
                    Releazio.shared.openAppStore(updateState: state)
                }
            }
            
            // Version view
            if let state = updateState {
                VersionView(
                    updateState: state,
                    onUpdateTap: {
                        Releazio.shared.openAppStore(updateState: state)
                    }
                )
            }
        }
        .onAppear {
            checkUpdates()
        }
        .sheet(isPresented: $showUpdatePopup) {
            if let state = updateState {
                ReleazioUpdatePromptView(
                    updateState: state,
                    style: .native,
                    onUpdate: {
                        Releazio.shared.openAppStore(updateState: state)
                        showUpdatePopup = false
                    },
                    onSkip: { remaining in
                        if remaining == 0 {
                            showUpdatePopup = false
                        }
                    },
                    onClose: {
                        Releazio.shared.markPopupAsShown(
                            version: state.currentVersion,
                            updateType: state.updateType
                        )
                        showUpdatePopup = false
                    },
                    onInfoTap: {
                        Releazio.shared.openPostURL(updateState: state)
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
                    
                    // Auto-show popup if needed
                    if state.shouldShowPopup {
                        showUpdatePopup = true
                    }
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
}
```

### Complete UIKit Example

```swift
import UIKit
import Releazio

class ViewController: UIViewController {
    private var updateState: UpdateState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUpdates()
    }
    
    private func checkUpdates() {
        Task {
            do {
                let state = try await Releazio.shared.checkUpdates()
                await MainActor.run {
                    self.updateState = state
                    self.updateUI()
                    
                    // Auto-show popup if needed
                    if state.shouldShowPopup {
                        self.showUpdatePopup(state: state)
                    }
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    private func updateUI() {
        guard let state = updateState else { return }
        
        // Show badge if needed (type 0)
        if state.shouldShowBadge {
            // Add BadgeView to UI
        }
        
        // Show update button if needed (type 1)
        if state.shouldShowUpdateButton {
            // Add update button to UI
        }
        
        // Show version view
        let versionView = VersionUIKitView(
            updateState: state
        )
        versionView.onUpdateTap = {
            Releazio.shared.openAppStore(updateState: state)
        }
        // Add to view hierarchy
    }
    
    private func showUpdatePopup(state: UpdateState) {
        let viewController = ReleazioUpdatePromptViewController(
            updateState: state,
            onUpdate: {
                Releazio.shared.openAppStore(updateState: state)
                self.dismiss(animated: true)
            },
            onSkip: { remaining in
                if remaining == 0 {
                    self.dismiss(animated: true)
                }
            },
            onClose: {
                Releazio.shared.markPopupAsShown(
                    version: state.currentVersion,
                    updateType: state.updateType
                )
                self.dismiss(animated: true)
            },
            onInfoTap: {
                Releazio.shared.openPostURL(updateState: state)
            }
        )
        
        present(viewController, animated: true)
    }
}
```

## SwiftUI Integration

### ReleazioUpdatePromptView

Modal popup with two styles:

#### Native Style (Modal Card)

```swift
ReleazioUpdatePromptView(
    updateState: updateState,
    style: .native,
    onUpdate: {
        Releazio.shared.openAppStore(updateState: updateState)
    },
    onSkip: { remaining in
        print("Remaining: \(remaining)")
    },
    onClose: {
        // Close handler
    },
    onInfoTap: {
        Releazio.shared.openPostURL(updateState: updateState)
    }
)
.sheet(isPresented: $showPopup) {
    // Present as sheet
}
```

#### Olimp Style (Full Screen)

```swift
ReleazioUpdatePromptView(
    updateState: updateState,
    style: .olimp,
    onUpdate: {
        Releazio.shared.openAppStore(updateState: updateState)
    }
)
.fullScreenCover(isPresented: $showPopup) {
    // Present full screen
}
```

### VersionView

Display version with update button:

```swift
                VersionView(
                    updateState: updateState,
                    onUpdateTap: {
                        Releazio.shared.openAppStore(updateState: updateState)
                    }
                )
                
                // With custom colors
                VersionView(
                    updateState: updateState,
                    customColors: UIComponentColors(
                        updateButtonColor: Color(red: 0.2, green: 0.6, blue: 1.0),
                        updateButtonTextColor: .white
                    ),
                    onUpdateTap: {
                        Releazio.shared.openAppStore(updateState: updateState)
                    }
                )
```

### BadgeView

Indicator for new updates:

```swift
if updateState.shouldShowBadge {
    BadgeView(
        text: "New",
        backgroundColor: .yellow,
        textColor: .black
    )
    .onTapGesture {
        Releazio.shared.openPostURL(updateState: updateState)
    }
}
```

### ChangelogView

Display changelog with WebView:

```swift
.sheet(isPresented: $showChangelog) {
    NavigationView {
        ChangelogView(changelog: changelog) {
            showChangelog = false
        }
    }
}
```

## UIKit Integration

### ReleazioUpdatePromptViewController

```swift
let viewController = ReleazioUpdatePromptViewController(
    updateState: updateState,
    onUpdate: {
        Releazio.shared.openAppStore(updateState: updateState)
    },
    onSkip: { remaining in
        // Handle skip
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

### VersionUIKitView

```swift
let versionView = VersionUIKitView(
    updateState: updateState
)
versionView.onUpdateTap = {
    Releazio.shared.openAppStore(updateState: updateState)
}

view.addSubview(versionView)
NSLayoutConstraint.activate([
    versionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
    versionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    versionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
    versionView.heightAnchor.constraint(equalToConstant: 50)
])
```

### ChangelogViewController

```swift
let changelogVC = ChangelogViewController(changelog: changelog)
present(changelogVC, animated: true)
```

## Localization

### Supported Locales

- `"en"` — English
- `"ru"` — Russian

### Setting Locale

Set locale during configuration:

```swift
let configuration = ReleazioConfiguration(
    apiKey: "your-key",
    locale: "ru"  // Russian
)
```

Or pass to UI components:

```swift
VersionView(
    updateState: updateState
)
```

### Custom Localization

Localization strings are located in:
- `Sources/Releazio/Resources/en.lproj/Localizable.strings`
- `Sources/Releazio/Resources/ru.lproj/Localizable.strings`

## Error Handling

### Comprehensive Error Handling

```swift
Task {
    do {
        let updateState = try await Releazio.shared.checkUpdates()
        // Success
    } catch ReleazioError.configurationMissing {
        print("SDK not configured. Call Releazio.configure() first.")
    } catch ReleazioError.networkError(let error) {
        print("Network error: \(error.localizedDescription)")
    } catch ReleazioError.apiError(let code, let message) {
        print("API error [\(code)]: \(message ?? "Unknown")")
    } catch ReleazioError.noInternetConnection {
        print("No internet connection")
        // Show offline message
    } catch {
        print("Unknown error: \(error)")
    }
}
```

### Retry Logic

```swift
func checkUpdatesWithRetry(maxRetries: Int = 3) async {
    var retries = 0
    
    while retries < maxRetries {
        do {
            let updateState = try await Releazio.shared.checkUpdates()
            // Success
            break
        } catch {
            retries += 1
            if retries >= maxRetries {
                // Final failure
                print("Failed after \(maxRetries) retries")
            } else {
                // Wait before retry
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            }
        }
    }
}
```

## Best Practices

### 1. Early Configuration

Configure SDK as early as possible:

```swift
@main
struct App: SwiftUI.App {
    init() {
        // Configure immediately
        configureReleazio()
    }
}

private func configureReleazio() {
    let config = ReleazioConfiguration(
        apiKey: apiKey,
        locale: "ru"
    )
    Releazio.configure(with: config)
}
```

### 2. Periodic Update Checks

Check for updates on app launch and periodically:

```swift
class AppLifecycleManager {
    func applicationDidBecomeActive() {
        Task {
            await checkUpdates()
        }
    }
    
    private func checkUpdates() async {
        do {
            let state = try await Releazio.shared.checkUpdates()
            // Handle update state
        } catch {
            // Handle error
        }
    }
}
```

### 3. UI Thread Safety

Always update UI on main thread:

```swift
Task {
    let updateState = try await Releazio.shared.checkUpdates()
    
    await MainActor.run {
        // Update UI here
        self.updateState = updateState
        self.showPopup = updateState.shouldShowPopup
    }
}
```

### 4. User Experience

- Don't interrupt users with non-critical updates
- Show popups only when appropriate
- Respect user dismissals and skip preferences
- Provide clear update messaging

### 5. Testing

Test all update types:

```swift
// Test different update types from API
func testUpdateType(type: Int) async {
    // Mock API response with specific update_type
    let state = try await Releazio.shared.checkUpdates()
    
    switch type {
    case 0:
        XCTAssertTrue(state.shouldShowBadge)
    case 1:
        XCTAssertTrue(state.shouldShowUpdateButton)
    case 2, 3:
        XCTAssertTrue(state.shouldShowPopup)
    default:
        break
    }
}
```

## Troubleshooting

### SDK Not Configured

**Error:** `ReleazioError.configurationMissing`

**Solution:** Ensure `Releazio.configure()` is called before any SDK methods:

```swift
// ✅ Correct
Releazio.configure(with: config)
let state = try await Releazio.shared.checkUpdates()

// ❌ Wrong
let state = try await Releazio.shared.checkUpdates()  // Error!
Releazio.configure(with: config)
```

### Network Errors

**Error:** `ReleazioError.networkError` or `noInternetConnection`

**Solutions:**
1. Check internet connectivity
2. Verify API key is correct
3. Check network timeout settings
4. Test API endpoint accessibility

### UI Not Showing

**Symptoms:** Popup or UI components don't appear

**Solutions:**
1. Ensure UI updates are on main thread
2. Verify `updateState` is not `nil`
3. Check `shouldShowPopup`/`shouldShowBadge` flags
4. Ensure view controllers are properly presented

### Wrong Update Type Behavior

**Symptoms:** Wrong UI showing or missing features

**Solutions:**
1. Verify API returns correct `update_type` (0, 1, 2, 3)
2. Check `UpdateState` flags (`shouldShowBadge`, `shouldShowPopup`, etc.)
3. Ensure proper tracking (`markPopupAsShown`, `markPostAsOpened`)

### Debug Mode

Enable debug logging:

```swift
let config = ReleazioConfiguration(
    apiKey: "your-key",
    debugLoggingEnabled: true  // Enable debug logs
)
Releazio.configure(with: config)
```

Debug logs will show:
- API requests and responses
- Update state calculations
- Local storage operations
- URL opening attempts

## Getting Help

- 📖 [API Reference](API.md) — Complete API documentation
- 📖 [README](../README.md) — Main SDK documentation
- 💻 [Examples](../Examples/) — Working code examples
- 🐛 [GitHub Issues](https://github.com/Releazio/releazio-sdk-ios/issues)
- 📧 support@releazio.com

---

**Happy integrating with Releazio! 🚀**
