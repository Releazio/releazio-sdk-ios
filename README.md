# Releazio iOS SDK

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Releazio iOS SDK** — современная библиотека для управления обновлениями приложений в iOS. SDK предоставляет полный набор инструментов для проверки обновлений, отображения changelog и управления различными типами обновлений.

## ✨ Основные возможности

- 🚀 **Проверка обновлений** — Автоматическая проверка наличия новых версий через API
- 🎯 **4 типа обновлений** — Поддержка latest, silent, popup и popup force режимов
- 📝 **Changelog** — Отображение изменений с поддержкой WebView для постов
- 🎨 **UI компоненты** — Готовые компоненты для SwiftUI и UIKit
- 🌍 **Локализация** — Поддержка английского и русского языков
- 🔔 **Бейджи и уведомления** — Индикаторы новых версий
- ⚙️ **Гибкая настройка** — Кастомизация цветов, локали и поведения

## 📋 Требования

- iOS 15.0+ / macOS 12.0+ / watchOS 8.0+ / tvOS 15.0+
- Swift 5.9+
- Xcode 14.0+

## 📦 Установка

### Swift Package Manager

**Добавьте в Xcode:**
1. File → Add Package Dependencies
2. Вставьте URL: `https://github.com/Releazio/releazio-sdk-ios`
3. Выберите версию и добавьте в проект

**Или в Package.swift:**
```swift
dependencies: [
    .package(url: "https://github.com/Releazio/releazio-sdk-ios", from: "1.0.0")
]
```

<!-- CocoaPods installation is not supported; use Swift Package Manager -->

## 🚀 Быстрый старт

### 1. Импортируйте SDK

```swift
import Releazio
```

### 2. Настройте SDK

```swift
@main
struct YourApp: App {
    init() {
        let configuration = ReleazioConfiguration(
            apiKey: "your-api-key",
            locale: "ru", // или "en"
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

### 3. Проверьте обновления

```swift
Task {
    do {
        let updateState = try await Releazio.shared.checkUpdates()
        
        // Проверьте нужно ли показывать попап
        if updateState.shouldShowPopup {
            // Покажите ReleazioUpdatePromptView
        }
        
        // Проверьте нужно ли показывать бейдж
        if updateState.shouldShowBadge {
            // Покажите BadgeView
        }
        
        // Проверьте нужно ли показывать кнопку обновления
        if updateState.shouldShowUpdateButton {
            // Покажите кнопку обновления
        }
    } catch {
        print("Ошибка проверки обновлений: \(error)")
    }
}
```

## 📚 Типы обновлений

SDK поддерживает 4 типа обновлений в соответствии с API:

- **Type 0 (latest)** — Показывается бейдж, при клике открывается post_url
- **Type 1 (silent)** — Только кнопка "Обновить", попап не показывается
- **Type 2 (popup)** — Закрываемый попап с поддержкой show_interval
- **Type 3 (popup force)** — Незакрываемый попап с ограниченным количеством пропусков (skip_attempts)

## 🎨 UI компоненты

### SwiftUI

#### ReleazioUpdatePromptView
Попап для обновлений с поддержкой двух стилей: Native iOS Alert и InAppUpdate.

```swift
ReleazioUpdatePromptView(
    updateState: updateState,
    style: .native, // или .inAppUpdate
    locale: "ru",
    onUpdate: {
        Releazio.shared.openAppStore(updateState: updateState)
    },
    onSkip: { remaining in
        print("Осталось пропусков: \(remaining)")
    },
    onClose: {
        // Закрыть попап
    },
    onInfoTap: {
        Releazio.shared.openPostURL(updateState: updateState)
    }
)
```

#### VersionView
Компонент для отображения версии приложения с кнопкой обновления.

```swift
VersionView(
    updateState: updateState,
    locale: "ru",
    onUpdateTap: {
        Releazio.shared.openAppStore(updateState: updateState)
    }
)
```

#### BadgeView
Бейдж-индикатор для новых обновлений.

```swift
BadgeView(
    text: localization.badgeNewText,
    backgroundColor: .yellow,
    textColor: .black
)
```

#### ChangelogView
Отображение changelog с поддержкой WebView для загрузки постов.

```swift
ChangelogView(changelog: changelog)
```

### UIKit

#### ReleazioUpdatePromptViewController

```swift
let viewController = ReleazioUpdatePromptViewController(
    updateState: updateState,
    locale: "ru",
    onUpdate: {
        Releazio.shared.openAppStore(updateState: updateState)
    },
    onSkip: { remaining in
        print("Осталось пропусков: \(remaining)")
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

```swift
let versionView = VersionUIKitView(
    updateState: updateState,
    locale: "ru"
)

versionView.onUpdateTap = {
    Releazio.shared.openAppStore(updateState: updateState)
}

view.addSubview(versionView)
// Настройте constraints
```

#### ChangelogViewController

```swift
let changelogVC = ChangelogViewController(changelog: changelog)
present(changelogVC, animated: true)
```

## 🔧 API Reference

### Основные методы

#### `checkUpdates() async throws -> UpdateState`
Главный метод для проверки обновлений. Возвращает `UpdateState` с полной информацией о состоянии обновлений.

```swift
let updateState = try await Releazio.shared.checkUpdates()
```

#### `openAppStore(updateState:) -> Bool`
Открывает App Store для обновления приложения.

```swift
Releazio.shared.openAppStore(updateState: updateState)
```

#### `openPostURL(updateState:) -> Bool`
Открывает URL поста (для type 0 или при клике на кнопку информации).

```swift
Releazio.shared.openPostURL(updateState: updateState)
```

#### `markPostAsOpened(postURL:)`
Отмечает пост как открытый (для type 0, чтобы скрыть бейдж).

```swift
Releazio.shared.markPostAsOpened(postURL: postURL)
```

#### `markPopupAsShown(version:updateType:)`
Отмечает попап как показанный (для type 2, 3).

```swift
Releazio.shared.markPopupAsShown(
    version: updateState.currentVersion,
    updateType: updateState.updateType
)
```

#### `skipUpdate(version:) -> Int`
Пропускает обновление и возвращает количество оставшихся попыток (для type 3).

```swift
let remaining = Releazio.shared.skipUpdate(version: updateState.currentVersion)
```

### UpdateState

Структура, возвращаемая методом `checkUpdates()`, содержит:

- `updateType: Int` — Тип обновления (0, 1, 2, 3)
- `shouldShowBadge: Bool` — Показывать ли бейдж (type 0)
- `shouldShowPopup: Bool` — Показывать ли попап (type 2, 3)
- `shouldShowUpdateButton: Bool` — Показывать ли кнопку обновления (type 1)
- `remainingSkipAttempts: Int` — Осталось пропусков (type 3)
- `channelData: ChannelData` — Полные данные из API
- `badgeURL: String?` — URL для открытия при клике на бейдж
- `updateURL: String?` — URL для обновления приложения
- `currentVersionName: String` — Текущая версия приложения (для отображения)
- `latestVersionName: String` — Последняя доступная версия (для отображения)
- `isUpdateAvailable: Bool` — Доступно ли обновление

## ⚙️ Конфигурация

### ReleazioConfiguration

```swift
let configuration = ReleazioConfiguration(
    apiKey: "your-api-key",                      // Обязательно
    debugLoggingEnabled: false,                   // По умолчанию: false
    networkTimeout: 30,                          // По умолчанию: 30 секунд
    analyticsEnabled: true,                       // По умолчанию: true
    cacheExpirationTime: 3600,                    // По умолчанию: 3600 секунд (1 час)
    locale: "en",                                 // По умолчанию: "en" (поддерживается "ru")
    badgeColor: UIColor.systemYellow              // По умолчанию: nil (system yellow)
)
```

### Параметры

- **apiKey** — API ключ для аутентификации (обязательно)
- **debugLoggingEnabled** — Включить отладочные логи
- **networkTimeout** — Таймаут сетевых запросов в секундах
- **analyticsEnabled** — Включить сбор аналитики
- **cacheExpirationTime** — Время жизни кэша в секундах
- **locale** — Локаль для локализации ("en" или "ru")
- **badgeColor** — Кастомный цвет бейджа (опционально)

## 🌍 Локализация

SDK поддерживает два языка:

- **en** — Английский
- **ru** — Русский

Локализованные строки:
- `update.title` — Заголовок попапа обновления
- `update.message` — Сообщение об обновлении
- `update.button.update` — Текст кнопки "Обновить"
- `update.button.skip` — Текст кнопки "Пропустить"
- `update.button.close` — Текст кнопки "Закрыть"
- `update.badge.new` — Текст бейджа "Новое"
- `update.whats.new` — Текст "Что нового"

## 📖 Документация

Подробная документация доступна в следующих файлах:

- **[API Documentation](./Documentation/API.md)** — Полная справка по API
- **[Integration Guide](./Documentation/Integration.md)** — Руководство по интеграции

Для генерации документации используйте:

```bash
jazzy --source-directory Sources/Releazio
```

## 💡 Примеры использования

Полный пример интеграции доступен в папке [Examples](./Examples/ReleazioExample/).

### Пример полной интеграции (SwiftUI)

```swift
import SwiftUI
import Releazio

struct ContentView: View {
    @State private var updateState: UpdateState?
    @State private var showUpdatePrompt = false
    
    var body: some View {
        VStack {
            // Ваш контент
            
            // Версия и кнопка обновления
            if let updateState = updateState {
                VersionView(
                    updateState: updateState,
                    locale: "ru",
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
                    locale: "ru",
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
                    
                    // Показываем попап если нужно
                    if state.shouldShowPopup {
                        showUpdatePrompt = true
                    }
                }
            } catch {
                print("Ошибка: \(error)")
            }
        }
    }
}
```

## 🐛 Обработка ошибок

SDK использует `ReleazioError` для обработки ошибок:

```swift
do {
    let updateState = try await Releazio.shared.checkUpdates()
} catch ReleazioError.configurationMissing {
    print("SDK не настроен")
} catch ReleazioError.apiError(let code, let message) {
    print("API ошибка: \(code) - \(message)")
} catch {
    print("Неизвестная ошибка: \(error)")
}
```

## 🤝 Поддержка

- 📧 Email: support@releazio.com
- 🐛 Issues: [GitHub Issues](https://github.com/Releazio/releazio-sdk-ios/issues)
- 📖 Документация: [Releazio Docs](https://releazio.com/docs)

## 📄 Лицензия

Releazio iOS SDK доступен под лицензией MIT. Смотрите [LICENSE](LICENSE) для деталей.

---

**Сделано с ❤️ командой Releazio**
