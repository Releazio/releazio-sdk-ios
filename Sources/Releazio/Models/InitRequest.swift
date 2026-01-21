//
//  InitRequest.swift
//  Releazio
//
//  Created by Releazio Team on 20.01.2026.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Request model for device initialization endpoint
public struct InitRequest: Codable {
    
    /// Distribution channel (e.g., "appstore" for iOS)
    public let channel: String
    
    /// Application bundle identifier
    public let appId: String?
    
    /// Application build version (CFBundleVersion)
    public let appVersionCode: String?
    
    /// Application version name (CFBundleShortVersionString)
    public let appVersionName: String?
    
    /// Operating system type (e.g., "ios" for iOS)
    public let osType: String
    
    /// User's region code
    public let region: String?
    
    /// Market packages (not applicable for iOS, nil or empty string)
    public let marketPackages: String?
    
    /// User's locale language code
    public let locale: String?
    
    /// OS version code (major version number)
    public let osVersionCode: String?
    
    /// Device manufacturer (e.g., "Apple" for iOS)
    public let deviceManufacturer: String
    
    /// Device brand (e.g., "Apple" for iOS)
    public let deviceBrand: String
    
    /// Device model
    public let deviceModel: String?
    
    /// SDK version
    public let sdkVersion: String?
    
    /// OS API level (nil for iOS)
    public let osApiLevel: String?
    
    /// Timezone identifier
    public let timezone: String?
    
    /// Device identifier
    public let deviceId: String?
    
    /// Screen width in points
    public let screenWidth: Int?
    
    /// Screen height in points
    public let screenHeight: Int?
    
    /// Screen scale (density)
    public let screenScale: Int?
    
    /// Whether device is emulator/simulator
    public let isEmulator: Bool?
    
    // MARK: - Coding Keys
    
    private enum CodingKeys: String, CodingKey {
        case channel
        case appId = "app_id"
        case appVersionCode = "app_version_code"
        case appVersionName = "app_version_name"
        case osType = "os_type"
        case region
        case marketPackages = "market_packages"
        case locale
        case osVersionCode = "os_version_code"
        case deviceManufacturer = "device_manufacturer"
        case deviceBrand = "device_brand"
        case deviceModel = "device_model"
        case sdkVersion = "sdk_version"
        case osApiLevel = "os_api_level"
        case timezone
        case deviceId = "device_id"
        case screenWidth = "screen_width"
        case screenHeight = "screen_height"
        case screenScale = "screen_scale"
        case isEmulator = "is_emulator"
    }
    
    // MARK: - Initialization
    
    public init(
        channel: String,
        appId: String?,
        appVersionCode: String?,
        appVersionName: String?,
        osType: String,
        region: String?,
        marketPackages: String?,
        locale: String?,
        osVersionCode: String?,
        deviceManufacturer: String,
        deviceBrand: String,
        deviceModel: String?,
        sdkVersion: String?,
        osApiLevel: String?,
        timezone: String?,
        deviceId: String?,
        screenWidth: Int?,
        screenHeight: Int?,
        screenScale: Int?,
        isEmulator: Bool?
    ) {
        self.channel = channel
        self.appId = appId
        self.appVersionCode = appVersionCode
        self.appVersionName = appVersionName
        self.osType = osType
        self.region = region
        self.marketPackages = marketPackages
        self.locale = locale
        self.osVersionCode = osVersionCode
        self.deviceManufacturer = deviceManufacturer
        self.deviceBrand = deviceBrand
        self.deviceModel = deviceModel
        self.sdkVersion = sdkVersion
        self.osApiLevel = osApiLevel
        self.timezone = timezone
        self.deviceId = deviceId
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
        self.screenScale = screenScale
        self.isEmulator = isEmulator
    }
}

/// Empty response for init endpoint (200 OK with no body)
public struct InitResponse: Codable {
    public init() {}
}
