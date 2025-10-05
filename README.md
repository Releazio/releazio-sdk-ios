# Releazio iOS SDK

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Releazio iOS SDK - современная библиотека для интеграции с платформой управления релизами Releazio в iOS приложениях.

## Возможности

- ✅ Проверка обновлений приложений
- ✅ Отображение changelog
- ✅ In-app уведомления о новых версиях
- ✅ Принудительные обновления
- ✅ Готовые UI компоненты (SwiftUI + UIKit)
- ✅ Кэширование и offline режим
- ✅ Аналитика использования
- ✅ Поддержка dependency injection
- ✅ Modern Swift с async/await

## Требования

- iOS 15.0+ / macOS 12.0+ / watchOS 8.0+ / tvOS 15.0+
- Swift 5.9+
- Xcode 14.0+

## Установка

### Swift Package Manager

Добавьте в `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/releazio-ios-sdk.git", from: "1.0.0")
]
```

Или в Xcode:
1. File → Add Package Dependencies
2. Вставьте URL: `https://github.com/your-org/releazio-ios-sdk.git`
3. Выберите версию и добавьте в проект

### CocoaPods

```ruby
pod 'Releazio', '~> 1.0'
```

## Быстрый старт

### 1. Импортируйте SDK

```swift
import Releazio
```

### 2. Настройте SDK

```swift
// В AppDelegate или SwiftUI App
let configuration = ReleazioConfiguration(
    apiKey: "your-api-key",
    environment: .production,
    applicationId: "your-app-id"
)

Releazio.configure(with: configuration)
```

### 3. Проверьте обновления

```swift
// Проверка наличия обновлений
Task {
    do {
        let hasUpdate = try await Releazio.shared.checkForUpdates()
        if hasUpdate {
            // Показать UI обновления
            Releazio.shared.showUpdatePrompt()
        }
    } catch {
        print("Error checking updates: \(error)")
    }
}
```

### 4. Отобразите changelog

```swift
// SwiftUI
ChangelogView(release: latestRelease)

// UIKit
let changelogVC = ChangelogViewController(release: latestRelease)
present(changelogVC, animated: true)
```

## Документация

Подробная документация доступна на [Documentation](./Documentation/) или с помощью Jazzy:

```bash
jazzy --source-directory Sources/Releazio
```

## Примеры

Смотрите [Examples](./Examples/) для полных примеров интеграции.

## Лицензия

Releazio iOS SDK доступен под лицензией MIT. Смотрите [LICENSE](LICENSE) для деталей.

## Поддержка

- 📧 Email: support@releazio.com
- 🐛 Issues: [GitHub Issues](https://github.com/your-org/releazio-ios-sdk/issues)
- 📖 Документация: [Releazio Docs](https://releazio.com/docs)