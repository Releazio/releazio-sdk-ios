//
//  ReleazioConfiguration.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Configuration object for Releazio SDK
public struct ReleazioConfiguration {

    // MARK: - Properties

    /// API key for authentication with Releazio API
    public let apiKey: String

    /// Enable debug logging
    public let debugLoggingEnabled: Bool

    /// Timeout for network requests (default: 30 seconds)
    public let networkTimeout: TimeInterval

    /// Enable analytics tracking
    public let analyticsEnabled: Bool

    /// Cache expiration time in seconds (default: 1 hour)
    public let cacheExpirationTime: TimeInterval
    
    /// Locale for SDK localization (default: "en")
    /// Supported locales: "en", "ru"
    public let locale: String
    
    /// Badge color for update indicator (optional, default: system yellow)
    #if canImport(UIKit)
    public let badgeColor: UIColor?
    #else
    // For platforms without UIKit, store as Any (not used)
    public let badgeColor: Any?
    #endif

    // MARK: - Initialization

    /// Initialize configuration with required parameters
    /// - Parameters:
    ///   - apiKey: API key for authentication
    ///   - debugLoggingEnabled: Enable debug logging (default: false)
    ///   - networkTimeout: Network timeout in seconds (default: 30)
    ///   - analyticsEnabled: Enable analytics tracking (default: true)
    ///   - cacheExpirationTime: Cache expiration time in seconds (default: 3600)
    ///   - locale: Locale identifier (default: "en", supported: "en", "ru")
    ///   - badgeColor: Custom badge color (optional, default: system yellow)
    #if canImport(UIKit)
    public init(
        apiKey: String,
        debugLoggingEnabled: Bool = false,
        networkTimeout: TimeInterval = 30,
        analyticsEnabled: Bool = true,
        cacheExpirationTime: TimeInterval = 3600,
        locale: String = "en",
        badgeColor: UIColor? = nil
    ) {
        self.apiKey = apiKey
        self.debugLoggingEnabled = debugLoggingEnabled
        self.networkTimeout = networkTimeout
        self.analyticsEnabled = analyticsEnabled
        self.cacheExpirationTime = cacheExpirationTime
        self.locale = locale
        self.badgeColor = badgeColor
    }
    #else
    public init(
        apiKey: String,
        debugLoggingEnabled: Bool = false,
        networkTimeout: TimeInterval = 30,
        analyticsEnabled: Bool = true,
        cacheExpirationTime: TimeInterval = 3600,
        locale: String = "en",
        badgeColor: Any? = nil
    ) {
        self.apiKey = apiKey
        self.debugLoggingEnabled = debugLoggingEnabled
        self.networkTimeout = networkTimeout
        self.analyticsEnabled = analyticsEnabled
        self.cacheExpirationTime = cacheExpirationTime
        self.locale = locale
        self.badgeColor = badgeColor
    }
    #endif

    // MARK: - Validation

    /// Validate configuration parameters
    /// - Returns: True if configuration is valid
    public func validate() -> Bool {
        return !apiKey.isEmpty &&
               apiKey.count >= 8 && // Basic validation for API key format
               networkTimeout > 0 &&
               cacheExpirationTime > 0
    }
}

// MARK: - Configuration Extensions

extension ReleazioConfiguration: Equatable {
    public static func == (lhs: ReleazioConfiguration, rhs: ReleazioConfiguration) -> Bool {
        return lhs.apiKey == rhs.apiKey &&
               lhs.debugLoggingEnabled == rhs.debugLoggingEnabled &&
               lhs.networkTimeout == rhs.networkTimeout &&
               lhs.analyticsEnabled == rhs.analyticsEnabled &&
               lhs.cacheExpirationTime == rhs.cacheExpirationTime &&
               lhs.locale == rhs.locale
        // badgeColor comparison is complex with conditional compilation, skip for now
    }
}