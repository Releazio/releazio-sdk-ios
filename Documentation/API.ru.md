# Releazio iOS SDK Справочник API

Полный справочник API для интеграторов Releazio iOS SDK.

## Содержание

- [Основной SDK](#основной-sdk)
- [Конфигурация](#конфигурация)
- [Управление обновлениями](#управление-обновлениями)
- [Модели данных](#модели-данных)
- [UI компоненты](#ui-компоненты)
- [Локализация](#локализация)
- [Обработка ошибок](#обработка-ошибок)

## Основной SDK

### Releazio

Главная точка входа для Releazio SDK.

#### Свойства

```swift
public class Releazio {
    /// Общий singleton экземпляр Releazio SDK
    public static let shared: Releazio
}
```

#### Методы

##### `configure(with:)`

Настройка SDK с вашим API ключом и параметрами.

```swift
public static func configure(with configuration: ReleazioConfiguration)
```

**Параметры:**
- `configuration`: Объект `ReleazioConfiguration` с API ключом и настройками

**Примечание:** Этот метод автоматически вызывает `init()` в фоне для отправки информации об устройстве на сервер для статистики API запросов. Это включает device ID, размеры экрана, timezone, версию ОС и другие данные об устройстве. Ошибки при `init()` логируются (если `debugLoggingEnabled` равен `true`), но не прерывают процесс инициализации SDK.

**Пример:**
```swift
let config = ReleazioConfiguration(
    apiKey: "your-api-key",
    locale: "ru",
    debugLoggingEnabled: true
)
Releazio.configure(with: config)
// Информация об устройстве автоматически отправляется на сервер в фоне
```

##### `checkUpdates()`

Основной метод для проверки обновлений. Возвращает полную информацию о состоянии обновлений.

```swift
public func checkUpdates() async throws -> UpdateState
```

**Возвращает:**
- `UpdateState` — Полная информация о состоянии обновлений

**Выбрасывает:**
- `ReleazioError.configurationMissing` — Если SDK не настроен
- `ReleazioError.networkError` — Если сетевой запрос не удался
- `ReleazioError.apiError` — Если API вернул ошибку

**Пример:**
```swift
Task {
    do {
        let updateState = try await Releazio.shared.checkUpdates()
        
        if updateState.shouldShowPopup {
            // Показать попап
        }
        
        if updateState.shouldShowBadge {
            // Показать бейдж
        }
        
        if updateState.shouldShowUpdateButton {
            // Показать кнопку обновления
        }
    } catch {
        print("Ошибка: \(error)")
    }
}
```

##### `openAppStore(updateState:)`

Открыть App Store для обновления приложения.

```swift
public func openAppStore(updateState: UpdateState) -> Bool
```

**Параметры:**
- `updateState`: Объект `UpdateState`, содержащий URL обновления

**Возвращает:**
- `Bool` — `true` если URL успешно открыт, `false` в противном случае

**Пример:**
```swift
let success = Releazio.shared.openAppStore(updateState: updateState)
if !success {
    print("Не удалось открыть App Store")
}
```

##### `openPostURL(updateState:)`

Открыть URL поста (при клике на бейдж или кнопку информации).

```swift
public func openPostURL(updateState: UpdateState) -> Bool
```

**Параметры:**
- `updateState`: Объект `UpdateState`, содержащий URL поста

**Возвращает:**
- `Bool` — `true` если URL успешно открыт, `false` в противном случае

**Примечание:** Автоматически отмечает пост как открытый для `updateType == 0`.

**Пример:**
```swift
let success = Releazio.shared.openPostURL(updateState: updateState)
```

##### `markPostAsOpened(postURL:)`

Отметить пост как открытый (скрывает бейдж для `updateType == 0`).

```swift
public func markPostAsOpened(postURL: String)
```

**Параметры:**
- `postURL`: Строка с URL поста

**Пример:**
```swift
Releazio.shared.markPostAsOpened(postURL: "https://releazio.com/post/123")
```

##### `markPopupAsShown(version:updateType:)`

Отметить попап как показанный (для логики `show_interval`).

```swift
public func markPopupAsShown(version: String, updateType: Int)
```

**Параметры:**
- `version`: Идентификатор версии
- `updateType`: Тип обновления (2 или 3)

**Пример:**
```swift
Releazio.shared.markPopupAsShown(
    version: updateState.currentVersion,
    updateType: updateState.updateType
)
```

##### `skipUpdate(version:)`

Пропустить обновление и уменьшить счетчик пропусков (для `updateType == 3`).

```swift
public func skipUpdate(version: String) -> Int
```

**Параметры:**
- `version`: Идентификатор версии

**Возвращает:**
- `Int` — Оставшееся количество пропусков после уменьшения

**Пример:**
```swift
let remaining = Releazio.shared.skipUpdate(version: updateState.currentVersion)
print("Осталось пропусков: \(remaining)")

if remaining == 0 {
    // Пропусков не осталось, закрыть попап
}
```

##### `getConfig()`

Получить конфигурацию из API напрямую.

```swift
public func getConfig() async throws -> ConfigResponse
```

**Возвращает:**
- `ConfigResponse` — Полный ответ конфигурации из API

**Пример:**
```swift
Task {
    do {
        let config = try await Releazio.shared.getConfig()
        let channelData = config.data.first
        print("Последняя версия: \(channelData?.appVersionName ?? "unknown")")
    } catch {
        print("Ошибка: \(error)")
    }
}
```

##### `getConfiguration()`

Получить текущую конфигурацию SDK.

```swift
public func getConfiguration() -> ReleazioConfiguration?
```

**Возвращает:**
- `ReleazioConfiguration?` — Текущая конфигурация или `nil` если не настроена

##### `reset()`

Сбросить конфигурацию SDK и очистить кэш.

```swift
public func reset()
```

#### Устаревшие методы

##### `checkForUpdates()` ⚠️ Устарел

**Устарел:** Используйте `checkUpdates()` вместо этого.

```swift
@available(*, deprecated)
public func checkForUpdates() async throws -> Bool
```

Этот метод возвращает только булево значение и не предоставляет полную информацию о состоянии обновлений. Используйте `checkUpdates()` для полного состояния обновлений.

##### `getReleases()` ⚠️ Устарел

**Устарел:** Используйте `checkUpdates()` для получения состояния обновлений с полными данными канала.

```swift
@available(*, deprecated)
public func getReleases() async throws -> [Release]
```

##### `getLatestRelease()` ⚠️ Устарел

**Устарел:** Используйте `checkUpdates()` вместо этого.

```swift
@available(*, deprecated)
public func getLatestRelease() async throws -> Release?
```

Этот метод не предоставляет тип обновления и информацию о состоянии, необходимую для правильной обработки обновлений.

##### `showUpdatePrompt()` ⚠️ Устарел

**Устарел:** Не реализован. Используйте UI компоненты напрямую.

```swift
@available(*, deprecated)
public func showUpdatePrompt()
```

Этот метод не реализован. Используйте `ReleazioUpdatePromptView` (SwiftUI) или `ReleazioUpdatePromptViewController` (UIKit) напрямую для показа попапов обновлений.

**Примечание:** Для обратной совместимости доступны следующие устаревшие методы:
- ~~`checkForUpdates() async throws -> Bool`~~ - **Устарел**: Используйте `checkUpdates()` вместо этого
- ~~`getReleases() async throws -> [Release]`~~ - **Устарел**: Используйте `checkUpdates()` для получения состояния обновлений с полными данными
- ~~`getLatestRelease() async throws -> Release?`~~ - **Устарел**: Используйте `checkUpdates()` вместо этого
- `getChangelog(for:) async throws -> Changelog` - Доступен для специфических случаев

## Конфигурация

### ReleazioConfiguration

Объект конфигурации для инициализации SDK.

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

#### Параметры

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `apiKey` | `String` | **Обязательно** | Ваш Releazio API ключ |
| `debugLoggingEnabled` | `Bool` | `false` | Включить отладочные логи |
| `networkTimeout` | `TimeInterval` | `30` | Таймаут сетевых запросов в секундах |
| `analyticsEnabled` | `Bool` | `true` | Включить аналитику |
| `cacheExpirationTime` | `TimeInterval` | `3600` | Время жизни кэша в секундах (1 час) |
| `locale` | `String` | `"en"` | Идентификатор локали (`"en"` или `"ru"`) |
| `badgeColor` | `UIColor?` | `nil` | Кастомный цвет бейджа (по умолчанию: системный желтый) |

#### Пример

```swift
let configuration = ReleazioConfiguration(
    apiKey: "your-api-key",
    locale: "ru",
    debugLoggingEnabled: true,
    badgeColor: UIColor.systemOrange
)
Releazio.configure(with: configuration)
```

## Управление обновлениями

### UpdateState

Полная информация о состоянии, возвращаемая методом `checkUpdates()`.

```swift
public struct UpdateState {
    /// Тип обновления из API (0, 1, 2, 3)
    public let updateType: Int
    
    /// Нужно ли показывать бейдж (для типа 0)
    public let shouldShowBadge: Bool
    
    /// Нужно ли показывать попап (для типов 2, 3)
    public let shouldShowPopup: Bool
    
    /// Нужно ли показывать кнопку обновления (для типа 1)
    public let shouldShowUpdateButton: Bool
    
    /// Оставшееся количество пропусков (для типа 3)
    public let remainingSkipAttempts: Int
    
    /// Полные данные канала из API
    public let channelData: ChannelData
    
    /// URL для открытия при клике на бейдж (post_url или posts_url)
    public let badgeURL: String?
    
    /// URL для обновления приложения (app_url или app_deeplink)
    public let updateURL: String?
    
    /// Текущий версионный код приложения (для сравнения)
    public let currentVersion: String
    
    /// Последний доступный версионный код из API
    public let latestVersion: String
    
    /// Текущее имя версии приложения (для отображения, например "1.2.3")
    public let currentVersionName: String
    
    /// Последнее доступное имя версии из API (например "2.5.1")
    public let latestVersionName: String
    
    /// Доступно ли обновление (сравнение версий)
    public let isUpdateAvailable: Bool
}
```

### Типы обновлений

SDK поддерживает 4 типа обновлений:

| Тип | Название | Описание | Поведение |
|-----|----------|----------|-----------|
| `0` | `latest` | Последнее доступное | Показывать только бейдж, открывать post_url при клике |
| `1` | `silent` | Тихое обновление | Показывать только кнопку обновления, без попапа |
| `2` | `popup` | Попап обновления | Показывать закрываемый попап с логикой show_interval |
| `3` | `popup force` | Принудительный попап | Показывать незакрываемый попап с skip_attempts |

## Модели данных

### ConfigResponse

Ответ от API endpoint `getConfig`.

```swift
public struct ConfigResponse: Codable {
    /// Домашний URL приложения
    public let homeUrl: String
    
    /// Массив данных каналов
    public let data: [ChannelData]
}
```

### ChannelData

Информация об обновлениях для конкретного канала.

```swift
public struct ChannelData: Codable {
    /// Тип канала (например, "appstore")
    public let channel: String
    
    /// Версионный код приложения (номер сборки)
    public let appVersionCode: String
    
    /// Имя версии приложения (отображаемая версия, например "2.5.1")
    public let appVersionName: String
    
    /// Deep link URL приложения (itms-apps://...)
    public let appDeeplink: String?
    
    /// Имя пакета канала (null для iOS)
    public let channelPackageName: String?
    
    /// URL App Store (https://apps.apple.com/...)
    public let appUrl: String?
    
    /// URL поста (одиночный пост)
    public let postUrl: String?
    
    /// URL постов (все посты)
    public let postsUrl: String?
    
    /// Тип обновления (0, 1, 2, 3)
    public let updateType: Int
    
    /// Сообщение об обновлении
    public let updateMessage: String
    
    /// Количество попыток пропуска (для типа 3)
    public let skipAttempts: Int
    
    /// Интервал показа в минутах (для типов 2, 3)
    public let showInterval: Int
    
    // Вычисляемые свойства
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

Модель changelog (используется для отображения постов).

```swift
public struct Changelog: Codable, Identifiable {
    public let id: String
    public let title: String
    public let content: String  // Может быть post_url для WebView
    public let releaseId: String
    public let createdAt: Date
}
```

## UI компоненты

### SwiftUI компоненты

#### ReleazioUpdatePromptView

Модальный попап для обновлений с двумя стилями: Native iOS Alert и InAppUpdate.

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

**Параметры:**
- `updateState`: `UpdateState` из `checkUpdates()`
- `style`: `.native` (по умолчанию: `.default`, что равно `.native`)
- `customColors`: Опциональные кастомные цвета для кнопок и текста (см. `UIComponentColors`)
- `customStrings`: Опциональные кастомные локализованные строки (см. `UILocalizationStrings`)
- `onUpdate`: Колбэк при нажатии на кнопку "Обновить"
- `onSkip`: Колбэк при пропуске (только для `updateType == 3`)
- `onClose`: Колбэк при закрытии попапа (только для `updateType == 2`)
- `onInfoTap`: Колбэк при нажатии на кнопку информации (?)

**Примечание:** Локаль определяется автоматически из системных настроек. SDK поддерживает английский ("en") и русский ("ru"), для остальных языков используется fallback на английский. Вы можете предоставить кастомные строки для любого языка через `customStrings`.

**Пример:**
```swift
// Базовое использование с автоматическим определением локали
ReleazioUpdatePromptView(
    updateState: updateState,
    style: .native,
    onUpdate: {
        Releazio.shared.openAppStore(updateState: updateState)
    }
)

// С кастомными цветами и строками
let customColors = UIComponentColors(
    updateButtonColor: .blue,
    updateButtonTextColor: .white
)

let customStrings = UILocalizationStrings(
    updateTitle: "Доступно обновление",
    updateMessage: "Кастомное сообщение",
    updateButtonText: "Обновить сейчас"
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

Компонент для отображения версии приложения с опциональной кнопкой обновления.

```swift
public struct VersionView: View {
    public init(
        updateState: UpdateState,
        customColors: UIComponentColors? = nil,
        customStrings: UILocalizationStrings? = nil,
        onUpdateTap: (() -> Void)? = nil
    )
    
    // Или инициализация с отдельными параметрами
    public init(
        version: String,
        isUpdateAvailable: Bool = false,
        customColors: UIComponentColors? = nil,
        customStrings: UILocalizationStrings? = nil,
        onUpdateTap: (() -> Void)? = nil
    )
}
```

**Параметры:**
- `updateState` или `version`/`isUpdateAvailable`: Информация о версии
- `customColors`: Опциональные кастомные цвета (поддерживаются `updateButtonColor`, `updateButtonTextColor`, `versionBackgroundColor`, `versionTextColor`)
- `customStrings`: Опциональные кастомные строки (поддерживаются `versionText`, `updateButtonText`)
- `onUpdateTap`: Колбэк при нажатии на кнопку обновления

**Примечание:** Локаль определяется автоматически из системных настроек.

**Пример:**
```swift
// Базовое использование
VersionView(
    updateState: updateState,
    onUpdateTap: {
        Releazio.shared.openAppStore(updateState: updateState)
    }
)

// С кастомными цветами
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

Компонент бейджа для индикации новых обновлений.

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

**Пример:**
```swift
if updateState.shouldShowBadge {
    BadgeView(
        text: "Новое",
        backgroundColor: .yellow,
        textColor: .black
    )
}
```

#### ChangelogView

Вид для отображения changelog с поддержкой WebView.

```swift
public struct ChangelogView: View {
    @State public var changelog: Changelog
    
    public init(changelog: Changelog, onDismiss: (() -> Void)? = nil)
}
```

**Примечание:** Если `changelog.content` содержит URL, он будет открыт в WebView.

**Пример:**
```swift
ChangelogView(changelog: changelog) {
    // Обработчик закрытия
}
```

### UIKit компоненты

#### ReleazioUpdatePromptViewController

ViewController для попапов обновлений.

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

**Примечание:** Локаль определяется автоматически из системных настроек.

**Пример:**
```swift
let viewController = ReleazioUpdatePromptViewController(
    updateState: updateState,
    onUpdate: {
        Releazio.shared.openAppStore(updateState: updateState)
    },
    onSkip: { remaining in
        print("Осталось: \(remaining)")
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

UIKit вид для отображения версии с кнопкой обновления.

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

**Примечание:** Локаль определяется автоматически из системных настроек.

**Пример:**
```swift
let versionView = VersionUIKitView(
    updateState: updateState
)
versionView.onUpdateTap = {
    Releazio.shared.openAppStore(updateState: updateState)
}
view.addSubview(versionView)
// Настроить constraints
```

#### ChangelogViewController

ViewController для отображения changelog.

```swift
public class ChangelogViewController: UIViewController {
    public init(changelog: Changelog)
}
```

## Локализация

SDK автоматически определяет системную локаль и поддерживает два встроенных языка:
- `"en"` — Английский (fallback)
- `"ru"` — Русский

Для других языков SDK использует fallback на английский. Вы можете предоставить кастомные локализованные строки для любого языка через `UILocalizationStrings`.

### Автоматическое определение локали

Локаль определяется автоматически из `Locale.current.languageCode`. Больше не нужно передавать параметр `locale` в UI компоненты.

### UIComponentColors

Конфигурация кастомных цветов для UI компонентов.

```swift
public struct UIComponentColors {
    public let updateButtonColor: Color?          // Фон кнопки обновления
    public let updateButtonTextColor: Color?       // Текст кнопки обновления
    public let skipButtonColor: Color?             // Фон кнопки пропуска
    public let skipButtonTextColor: Color?         // Текст кнопки пропуска
    public let closeButtonColor: Color?            // Цвет кнопки закрытия
    public let linkColor: Color?                   // Цвет ссылок (для "Что нового")
    public let badgeColor: Color?                  // Фон бейджа
    public let badgeTextColor: Color?              // Текст бейджа
    public let versionBackgroundColor: Color?       // Фон метки версии
    public let versionTextColor: Color?            // Текст метки версии
    public let primaryTextColor: Color?            // Основной текст (заголовки, сообщения)
    public let secondaryTextColor: Color?          // Вторичный текст (подзаголовки)
    
    public init(
        updateButtonColor: Color? = nil,
        updateButtonTextColor: Color? = nil,
        // ... другие цвета
    )
}
```

**Примечание:** Для UIKit используйте `UIColor` вместо `Color`.

**Пример:**
```swift
let customColors = UIComponentColors(
    updateButtonColor: .blue,
    updateButtonTextColor: .white,
    linkColor: .systemBlue
)
```

### UILocalizationStrings

Кастомные локализованные строки для UI компонентов. Все строки опциональны - если `nil`, будут использоваться строки SDK по умолчанию.

```swift
public struct UILocalizationStrings {
    public let updateTitle: String?                // Заголовок попапа обновления
    public let updateMessage: String?              // Сообщение об обновлении
    public let updateButtonText: String?           // Текст кнопки "Обновить"
    public let skipButtonText: String?             // Текст кнопки "Пропустить"
    public let closeButtonText: String?            // Текст кнопки "Закрыть"
    public let badgeNewText: String?              // Текст бейджа "Новое"
    public let whatsNewText: String?              // Текст ссылки "Что нового"
    public let versionText: String?               // Текст метки версии
    public let skipRemainingTextFormat: String?    // Формат оставшихся пропусков (используйте "%d" для числа)
    
    public init(
        updateTitle: String? = nil,
        updateMessage: String? = nil,
        // ... другие строки
    )
}
```

**Пример:**
```swift
let customStrings = UILocalizationStrings(
    updateTitle: "Доступно обновление",
    updateButtonText: "Обновить сейчас",
    skipRemainingTextFormat: "Осталось пропусков: %d"
)
```

### LocalizationManager

Вспомогательный класс для доступа к локализованным строкам (внутреннее использование). Включает статический метод для определения системной локали:

```swift
public static func detectSystemLocale() -> String
```

Возвращает `"ru"` если системный язык русский, иначе `"en"`.

## Обработка ошибок

### ReleazioError

Пользовательские типы ошибок для SDK.

```swift
public enum ReleazioError: Error, LocalizedError, Equatable {
    // Ошибки конфигурации
    case configurationMissing
    case invalidApiKey
    case invalidConfiguration(String)
    
    // Сетевые ошибки
    case networkError(Error)
    case invalidURL(String)
    case requestTimeout
    case noInternetConnection
    case serverError(statusCode: Int, message: String?)
    
    // Ошибки ответа API
    case invalidResponse
    case apiError(code: String, message: String?)
    case missingData(String)
    case decodingError(Error)
    
    // Ошибки валидации
    case invalidVersionFormat(String)
    case versionComparisonError
}
```

### Пример обработки ошибок

```swift
Task {
    do {
        let updateState = try await Releazio.shared.checkUpdates()
        // Обработка успеха
    } catch ReleazioError.configurationMissing {
        print("SDK не настроен")
    } catch ReleazioError.networkError(let error) {
        print("Сетевая ошибка: \(error)")
    } catch ReleazioError.apiError(let code, let message) {
        print("Ошибка API [\(code)]: \(message ?? "Неизвестно")")
    } catch {
        print("Неизвестная ошибка: \(error)")
    }
}
```

---

Для примеров интеграции см. [Руководство по интеграции](Integration.ru.md).

