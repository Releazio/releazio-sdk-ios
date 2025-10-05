# Руководство по интеграции Releazio iOS SDK

Полное пошаговое руководство по интеграции Releazio iOS SDK в ваше приложение.

## Содержание

- [Установка](#установка)
- [Быстрый старт](#быстрый-старт)
- [Конфигурация](#конфигурация)
- [Базовое использование](#базовое-использование)
- [Типы обновлений](#типы-обновлений)
- [Интеграция UI](#интеграция-ui)
- [Интеграция SwiftUI](#интеграция-swiftui)
- [Интеграция UIKit](#интеграция-uikit)
- [Локализация](#локализация)
- [Обработка ошибок](#обработка-ошибок)
- [Лучшие практики](#лучшие-практики)
- [Решение проблем](#решение-проблем)

## Установка

### Swift Package Manager (Рекомендуется)

1. В Xcode перейдите в **File → Add Package Dependencies**
2. Введите URL репозитория:
   ```
   https://github.com/swift2geek/releazio-ios-sdk
   ```
3. Выберите диапазон версий или конкретную версию
4. Добавьте в ваш app target
5. Нажмите **Add Package**

Альтернативно, добавьте в `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift2geek/releazio-ios-sdk", from: "1.0.0")
]
```

### Ручная установка

1. Клонируйте репозиторий
2. Перетащите папку `Sources/Releazio` в ваш проект Xcode
3. Убедитесь, что все файлы добавлены в ваш target
4. Настройте параметры сборки

## Быстрый старт

### 1. Импорт SDK

```swift
import Releazio
```

### 2. Настройка SDK

В вашем `AppDelegate` или SwiftUI `App`:

```swift
@main
struct YourApp: App {
    init() {
        let configuration = ReleazioConfiguration(
            apiKey: "your-api-key",
            locale: "ru",  // или "en"
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

### 3. Проверка обновлений

```swift
Task {
    do {
        let updateState = try await Releazio.shared.checkUpdates()
        
        // Проверить что показывать
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
        print("Ошибка проверки обновлений: \(error)")
    }
}
```

## Конфигурация

### Базовая конфигурация

```swift
let configuration = ReleazioConfiguration(
    apiKey: "your-api-key",
    debugLoggingEnabled: false,
    analyticsEnabled: true,
    locale: "ru"
)
```

### Полные параметры конфигурации

```swift
let configuration = ReleazioConfiguration(
    apiKey: "your-api-key",              // Обязательно
    debugLoggingEnabled: false,           // По умолчанию: false
    networkTimeout: 30,                  // По умолчанию: 30 секунд
    analyticsEnabled: true,               // По умолчанию: true
    cacheExpirationTime: 3600,           // По умолчанию: 3600 секунд (1 час)
    locale: "ru",                        // По умолчанию: "en" (поддерживается: "en", "ru")
    badgeColor: UIColor.systemYellow     // Опционально, по умолчанию: системный желтый
)
```

### Конфигурация для разных окружений

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

### Валидация конфигурации

```swift
let configuration = ReleazioConfiguration(apiKey: "your-key")
if configuration.validate() {
    Releazio.configure(with: configuration)
} else {
    print("Неверная конфигурация")
}
```

## Базовое использование

### Проверка обновлений

Основной метод для проверки обновлений — `checkUpdates()`, который возвращает полную информацию о состоянии:

```swift
Task {
    do {
        let updateState = try await Releazio.shared.checkUpdates()
        
        print("Тип обновления: \(updateState.updateType)")
        print("Текущая версия: \(updateState.currentVersionName)")
        print("Последняя версия: \(updateState.latestVersionName)")
        print("Обновление доступно: \(updateState.isUpdateAvailable)")
        
        // Обработка в зависимости от типа обновления
        switch updateState.updateType {
        case 0: // latest
            if updateState.shouldShowBadge {
                // Показать бейдж
            }
        case 1: // silent
            if updateState.shouldShowUpdateButton {
                // Показать кнопку обновления
            }
        case 2, 3: // popup, popup force
            if updateState.shouldShowPopup {
                // Показать попап
            }
        default:
            break
        }
    } catch {
        print("Ошибка: \(error)")
    }
}
```

### Открытие App Store

```swift
let success = Releazio.shared.openAppStore(updateState: updateState)
if success {
    print("App Store открыт")
} else {
    print("Не удалось открыть App Store")
}
```

### Открытие URL поста

```swift
let success = Releazio.shared.openPostURL(updateState: updateState)
// Автоматически отмечает пост как открытый для updateType == 0
```

### Ручное отслеживание постов

Для `updateType == 0`, отслеживайте когда пользователь открывает пост:

```swift
if updateState.updateType == 0 {
    Releazio.shared.markPostAsOpened(postURL: updateState.badgeURL ?? "")
}
```

### Отслеживание попапов

Для `updateType == 2` или `3`, отслеживайте когда попап показан:

```swift
if updateState.shouldShowPopup {
    // Показать попап
    Releazio.shared.markPopupAsShown(
        version: updateState.currentVersion,
        updateType: updateState.updateType
    )
}
```

### Пропуск обновлений

Для `updateType == 3`, обрабатывайте попытки пропуска:

```swift
let remaining = Releazio.shared.skipUpdate(version: updateState.currentVersion)

if remaining > 0 {
    print("Осталось пропусков: \(remaining)")
} else {
    // Пропусков не осталось, закрыть попап или принудительно обновить
}
```

## Типы обновлений

SDK поддерживает 4 типа обновлений с различным поведением:

### Тип 0: Latest (Только бейдж)

- Показывает индикатор бейджа
- Открывает `post_url` при клике на бейдж
- Бейдж скрывается после открытия поста
- Нет попапа или запроса на обновление

**Реализация:**
```swift
if updateState.shouldShowBadge {
    // Показать BadgeView
    BadgeView(text: "Новое")
        .onTapGesture {
            Releazio.shared.openPostURL(updateState: updateState)
        }
}
```

### Тип 1: Silent (Только кнопка обновления)

- Показывает только кнопку обновления
- Нет попапа или бейджа
- Интегратор решает где разместить кнопку

**Реализация:**
```swift
if updateState.shouldShowUpdateButton {
    Button("Обновить") {
        Releazio.shared.openAppStore(updateState: updateState)
    }
}
```

### Тип 2: Popup (Закрываемый)

- Показывает закрываемый попап
- Учитывает `show_interval` (минуты между показами)
- Может быть закрыт пользователем
- Имеет кнопку закрытия (X)

**Реализация:**
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

### Тип 3: Popup Force (Незакрываемый с пропуском)

- Показывает незакрываемый попап
- Имеет счетчик попыток пропуска
- Может быть пропущен ограниченное количество раз
- Нет кнопки закрытия (только когда попытки пропуска = 0)

**Реализация:**
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
                print("Осталось пропусков: \(remaining)")
            } else {
                // Пропусков не осталось, закрыть попап
            }
        }
    )
}
```

## Интеграция UI

### Полный пример SwiftUI

```swift
import SwiftUI
import Releazio

struct ContentView: View {
    @State private var updateState: UpdateState?
    @State private var showUpdatePopup = false
    @State private var showChangelog = false
    
    var body: some View {
        VStack {
            // Ваш контент
            
            // Бейдж (для типа 0)
            if let state = updateState, state.shouldShowBadge {
                BadgeView(text: "Новое")
                    .onTapGesture {
                        Releazio.shared.openPostURL(updateState: state)
                    }
            }
            
            // Кнопка обновления (для типа 1)
            if let state = updateState, state.shouldShowUpdateButton {
                Button("Обновить") {
                    Releazio.shared.openAppStore(updateState: state)
                }
            }
            
            // Компонент версии
            if let state = updateState {
                VersionView(
                    updateState: state,
                    locale: "ru",
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
                    locale: "ru",
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
                    
                    // Автоматически показать попап если нужно
                    if state.shouldShowPopup {
                        showUpdatePopup = true
                    }
                }
            } catch {
                print("Ошибка: \(error)")
            }
        }
    }
}
```

### Полный пример UIKit

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
                    
                    // Автоматически показать попап если нужно
                    if state.shouldShowPopup {
                        self.showUpdatePopup(state: state)
                    }
                }
            } catch {
                print("Ошибка: \(error)")
            }
        }
    }
    
    private func updateUI() {
        guard let state = updateState else { return }
        
        // Показать бейдж если нужно (тип 0)
        if state.shouldShowBadge {
            // Добавить BadgeView в UI
        }
        
        // Показать кнопку обновления если нужно (тип 1)
        if state.shouldShowUpdateButton {
            // Добавить кнопку обновления в UI
        }
        
        // Показать компонент версии
        let versionView = VersionUIKitView(
            updateState: state,
            locale: "ru"
        )
        versionView.onUpdateTap = {
            Releazio.shared.openAppStore(updateState: state)
        }
        // Добавить в иерархию view
    }
    
    private func showUpdatePopup(state: UpdateState) {
        let viewController = ReleazioUpdatePromptViewController(
            updateState: state,
            locale: "ru",
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

## Интеграция SwiftUI

### ReleazioUpdatePromptView

Модальный попап с двумя стилями:

#### Native Style (Модальная карточка)

```swift
                ReleazioUpdatePromptView(
                    updateState: updateState,
                    style: .native,
                    onUpdate: {
        Releazio.shared.openAppStore(updateState: updateState)
    },
    onSkip: { remaining in
        print("Осталось: \(remaining)")
    },
    onClose: {
        // Обработчик закрытия
    },
    onInfoTap: {
        Releazio.shared.openPostURL(updateState: updateState)
    }
)
.sheet(isPresented: $showPopup) {
    // Показать как sheet
}
```

#### Olimp Style (Полноэкранный)

```swift
ReleazioUpdatePromptView(
    updateState: updateState,
    style: .olimp,
    locale: "ru",
    onUpdate: {
        Releazio.shared.openAppStore(updateState: updateState)
    }
)
.fullScreenCover(isPresented: $showPopup) {
    // Показать полноэкранно
}
```

### VersionView

Отображение версии с кнопкой обновления:

```swift
                VersionView(
                    updateState: updateState,
                    onUpdateTap: {
                        Releazio.shared.openAppStore(updateState: updateState)
                    }
                )
                
                // С кастомными цветами
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

Индикатор для новых обновлений:

```swift
if updateState.shouldShowBadge {
    BadgeView(
        text: "Новое",
        backgroundColor: .yellow,
        textColor: .black
    )
    .onTapGesture {
        Releazio.shared.openPostURL(updateState: updateState)
    }
}
```

### ChangelogView

Отображение changelog с WebView:

```swift
.sheet(isPresented: $showChangelog) {
    NavigationView {
        ChangelogView(changelog: changelog) {
            showChangelog = false
        }
    }
}
```

## Интеграция UIKit

### ReleazioUpdatePromptViewController

```swift
        let viewController = ReleazioUpdatePromptViewController(
            updateState: updateState,
            onUpdate: {
        Releazio.shared.openAppStore(updateState: updateState)
    },
    onSkip: { remaining in
        // Обработка пропуска
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

## Локализация

### Поддерживаемые локали

- `"en"` — Английский
- `"ru"` — Русский

### Установка локали

Установите локаль при конфигурации:

```swift
let configuration = ReleazioConfiguration(
    apiKey: "your-key",
    locale: "ru"  // Русский
)
```

Или передайте в UI компоненты:

```swift
VersionView(
    updateState: updateState,
    locale: "ru"
)
```

### Кастомная локализация

Строки локализации находятся в:
- `Sources/Releazio/Resources/en.lproj/Localizable.strings`
- `Sources/Releazio/Resources/ru.lproj/Localizable.strings`

## Обработка ошибок

### Полная обработка ошибок

```swift
Task {
    do {
        let updateState = try await Releazio.shared.checkUpdates()
        // Успех
    } catch ReleazioError.configurationMissing {
        print("SDK не настроен. Вызовите Releazio.configure() сначала.")
    } catch ReleazioError.networkError(let error) {
        print("Сетевая ошибка: \(error.localizedDescription)")
    } catch ReleazioError.apiError(let code, let message) {
        print("Ошибка API [\(code)]: \(message ?? "Неизвестно")")
    } catch ReleazioError.noInternetConnection {
        print("Нет подключения к интернету")
        // Показать сообщение об офлайн режиме
    } catch {
        print("Неизвестная ошибка: \(error)")
    }
}
```

### Логика повторных попыток

```swift
func checkUpdatesWithRetry(maxRetries: Int = 3) async {
    var retries = 0
    
    while retries < maxRetries {
        do {
            let updateState = try await Releazio.shared.checkUpdates()
            // Успех
            break
        } catch {
            retries += 1
            if retries >= maxRetries {
                // Финальная неудача
                print("Не удалось после \(maxRetries) попыток")
            } else {
                // Подождать перед повторной попыткой
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 секунда
            }
        }
    }
}
```

## Лучшие практики

### 1. Ранняя конфигурация

Настройте SDK как можно раньше:

```swift
@main
struct App: SwiftUI.App {
    init() {
        // Настроить немедленно
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

### 2. Периодическая проверка обновлений

Проверяйте обновления при запуске приложения и периодически:

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
            // Обработать состояние обновления
        } catch {
            // Обработать ошибку
        }
    }
}
```

### 3. Безопасность UI потоков

Всегда обновляйте UI на главном потоке:

```swift
Task {
    let updateState = try await Releazio.shared.checkUpdates()
    
    await MainActor.run {
        // Обновить UI здесь
        self.updateState = updateState
        self.showPopup = updateState.shouldShowPopup
    }
}
```

### 4. Пользовательский опыт

- Не прерывайте пользователей некритичными обновлениями
- Показывайте попапы только когда уместно
- Уважайте закрытия и предпочтения пропуска пользователей
- Предоставляйте четкие сообщения об обновлениях

### 5. Тестирование

Протестируйте все типы обновлений:

```swift
// Тестирование разных типов обновлений из API
func testUpdateType(type: Int) async {
    // Мок ответ API с конкретным update_type
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

## Решение проблем

### SDK не настроен

**Ошибка:** `ReleazioError.configurationMissing`

**Решение:** Убедитесь, что `Releazio.configure()` вызывается перед любыми методами SDK:

```swift
// ✅ Правильно
Releazio.configure(with: config)
let state = try await Releazio.shared.checkUpdates()

// ❌ Неправильно
let state = try await Releazio.shared.checkUpdates()  // Ошибка!
Releazio.configure(with: config)
```

### Сетевые ошибки

**Ошибка:** `ReleazioError.networkError` или `noInternetConnection`

**Решения:**
1. Проверьте подключение к интернету
2. Убедитесь, что API ключ правильный
3. Проверьте настройки таймаута сети
4. Протестируйте доступность API endpoint

### UI не показывается

**Симптомы:** Попап или UI компоненты не появляются

**Решения:**
1. Убедитесь, что обновления UI на главном потоке
2. Проверьте что `updateState` не `nil`
3. Проверьте флаги `shouldShowPopup`/`shouldShowBadge`
4. Убедитесь, что view controllers правильно представлены

### Неправильное поведение типа обновления

**Симптомы:** Показывается неправильный UI или отсутствуют функции

**Решения:**
1. Убедитесь, что API возвращает правильный `update_type` (0, 1, 2, 3)
2. Проверьте флаги `UpdateState` (`shouldShowBadge`, `shouldShowPopup`, и т.д.)
3. Убедитесь в правильном отслеживании (`markPopupAsShown`, `markPostAsOpened`)

### Режим отладки

Включите логирование отладки:

```swift
let config = ReleazioConfiguration(
    apiKey: "your-key",
    debugLoggingEnabled: true  // Включить логи отладки
)
Releazio.configure(with: config)
```

Логи отладки покажут:
- API запросы и ответы
- Вычисления состояния обновлений
- Операции локального хранилища
- Попытки открытия URL

## Получение помощи

- 📖 [Справочник API](API.ru.md) — Полная документация API
- 📖 [README](../README.md) — Основная документация SDK
- 💻 [Примеры](../Examples/) — Рабочие примеры кода
- 🐛 [GitHub Issues](https://github.com/swift2geek/releazio-ios-sdk/issues)
- 📧 support@releazio.com

---

**Приятной интеграции с Releazio! 🚀**

