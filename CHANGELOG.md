# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.5] - 2025-01-XX

### Fixed
- Added skip button in type 3 (popup force) for SwiftUI (both native and InAppUpdate styles) and UIKit
- Fixed crash in UIKit when skip button constraints were added but button was not added to view
- Fixed skip attempts count logic - now properly initializes and persists attempts from API
- Fixed skip attempts reset issue on app restart in type 3 mode
- Fixed safe area issues in SwiftUI InAppUpdate style (content no longer overlaps safe area)

### Added
- Added InAppUpdate style support in UIKit (full-screen view with red header, matching SwiftUI implementation)

## [1.0.4] - 2025-01-XX

### Changed
- Migrated getConfig API parameters from HTTP headers to URL query parameters
- All device and app information now passed as query parameters instead of headers
- Removed custom headers (X-App-Build, X-Application-ID, X-OS-Version, etc.) from requests
- Only Authorization header remains for API key authentication

### Technical Details
- Parameters now passed in URL: channel, app_id, app_version_code, app_version_name, phone_locale_country, phone_locale_language, os_version_code, device_manufacturer, device_brand, device_model
- This change aligns with backend API requirements and Swagger documentation

## [1.0.3] - 2025-01-XX

### Changed
- Renamed update prompt style from "Olimp" to "InAppUpdate" for better clarity
- Updated all documentation and examples to reflect the new naming
- Updated Example app API key placeholder to prevent accidental commits

### Fixed
- Security: Removed hardcoded API key from Example app

## [1.0.0] - 2025-10-05

### Added
- Initial release of Releazio iOS SDK
- Core SDK functionality with configuration management
- Network layer with Alamofire integration
- Complete release management system
- SwiftUI and UIKit UI components
- Comprehensive caching system
- Analytics and tracking capabilities
- Full test suite
- Example application and documentation

## [1.0.0] - 2025-10-05

### Added
- **Core Architecture**
  - Protocol-based design for easy testing and extension
  - Dependency injection support
  - SOLID principles implementation
  - Modern Swift with async/await
  - Comprehensive error handling

- **Configuration System**
  - Environment-based configuration (dev/staging/prod)
  - API key validation
  - Debug logging support
  - Cache timeout configuration
  - Analytics enable/disable options

- **Network Layer**
  - Alamofire-based HTTP client
  - Automatic retry logic with exponential backoff
  - Request/response interceptors
  - Rate limiting support
  - Comprehensive error mapping

- **Data Models**
  - Release model with semantic versioning support
  - Changelog with categorized entries
  - AppVersion with comparison capabilities
  - API response wrapper with pagination
  - Analytics event tracking

- **Services**
  - ReleaseService for managing app releases
  - CacheService with memory and disk caching
  - AnalyticsService for usage tracking
  - NetworkManager for coordinated API calls

- **SwiftUI Components**
  - ChangelogView with theme support
  - UpdatePromptView for update notifications
  - ReleaseNotificationView for in-app alerts
  - NotificationManager for coordinated notifications

- **UIKit Components**
  - ChangelogViewController for legacy support
  - UpdatePromptViewController for modal updates
  - ReleazioButton with multiple styles
  - Theme system for consistent styling

- **Features**
  - Update checking with version comparison
  - Mandatory update enforcement
  - Offline mode support
  - Background update checking
  - Changelog display with categories
  - In-app notifications
  - Analytics tracking
  - Comprehensive caching

- **Testing**
  - Unit tests for all major components
  - Mock objects for isolated testing
  - Performance tests for critical paths
  - Integration test examples

- **Documentation**
  - Comprehensive README with setup guide
  - API documentation with Jazzy comments
  - Example application with all features
  - Integration guide and best practices

- **Developer Experience**
  - Swift Package Manager support
  - CocoaPods integration
  - Xcode friendly project structure
  - Debug logging and error reporting
  - Performance monitoring

### Technical Details
- **Minimum iOS Version:** 15.0
- **Swift Version:** 5.9+
- **Dependencies:** Alamofire (for networking)
- **Architecture:** MVVM with protocol-oriented programming
- **Testing:** XCTest with mock objects
- **Documentation:** Jazzy compatible comments

### Breaking Changes
- None (initial release)

### Deprecated
- None

### Security
- API key validation
- Secure data storage
- Network request encryption
- No sensitive data logging

### Performance
- Optimized caching strategies
- Efficient memory usage
- Minimal network overhead
- Background processing support

---

## Version History

### Pre-Release Development
- **v0.9.0** - Beta testing with select partners
- **v0.8.0** - Internal testing and bug fixes
- **v0.7.0** - Feature complete development version
- **v0.6.0** - UI components implementation
- **v0.5.0** - Core services implementation
- **v0.4.0** - Network layer development
- **v0.3.0** - Data models implementation
- **v0.2.0** - Project structure setup
- **v0.1.0** - Initial project creation

---

## Migration Guide

### From 0.x to 1.0.0
No migration required - this is the first stable release.

---

## Support

For questions, issues, or feature requests, please:
- 📖 Check our [Documentation](https://releazio.com/docs)
- 🐛 [Report Issues](https://github.com/Releazio/releazio-sdk-ios/issues)
- 📧 Contact [Support](mailto:support@releazio.com)
- 💬 Join our [Discord Community](https://discord.gg/releazio)

---

## Roadmap

### Upcoming Features (v1.1.0)
- [ ] WidgetKit support for home screen widgets
- [ ] Apple Watch companion app support
- [ ] Advanced analytics dashboard
- [ ] A/B testing framework integration
- [ ] Custom theme builder tool

### Future Enhancements (v1.2.0+)
- [ ] Multi-language support for UI components
- [ ] Advanced customization options
- [ ] Performance monitoring integration
- [ ] Machine learning based update recommendations
- [ ] Enterprise distribution support

---

**Thank you for using Releazio iOS SDK! 🚀**
