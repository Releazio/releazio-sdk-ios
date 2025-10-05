//
//  ConfigResponse.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation

/// Response model for getConfig endpoint
public struct ConfigResponse: Codable {
    
    /// Home URL for the application
    public let homeUrl: String
    
    /// Array of channel data
    public let data: [ChannelData]
    
    // MARK: - Coding Keys
    
    private enum CodingKeys: String, CodingKey {
        case homeUrl = "home_url"
        case data
    }
}

/// Channel data information
public struct ChannelData: Codable {
    
    /// Channel type (e.g., "appstore")
    public let channel: String
    
    /// App version code
    public let appVersionCode: String
    
    /// App version name
    public let appVersionName: String
    
    /// App deep link URL
    public let appDeeplink: String?
    
    /// Channel package name (null for iOS)
    public let channelPackageName: String?
    
    /// App store URL
    public let appUrl: String?
    
    /// Post URL
    public let postUrl: String?
    
    /// Posts URL
    public let postsUrl: String?
    
    /// Update type (0 = no update, 1 = optional, 2 = mandatory)
    public let updateType: Int
    
    /// Update message
    public let updateMessage: String
    
    /// Skip attempts count
    public let skipAttempts: Int
    
    /// Show interval
    public let showInterval: Int
    
    // MARK: - Coding Keys
    
    private enum CodingKeys: String, CodingKey {
        case channel
        case appVersionCode = "app_version_code"
        case appVersionName = "app_version_name"
        case appDeeplink = "app_deeplink"
        case channelPackageName = "channel_package_name"
        case appUrl = "app_url"
        case postUrl = "post_url"
        case postsUrl = "posts_url"
        case updateType = "update_type"
        case updateMessage = "update_message"
        case skipAttempts = "skip_attempts"
        case showInterval = "show_interval"
    }
    
    // MARK: - Computed Properties
    
    /// Whether update is available (any type > 0)
    public var hasUpdate: Bool {
        return updateType > 0
    }
    
    /// Whether update type is latest (0) - shows badge only
    public var isLatest: Bool {
        return updateType == 0
    }
    
    /// Whether update type is silent (1) - only update button, no popup
    public var isSilent: Bool {
        return updateType == 1
    }
    
    /// Whether update type is popup (2) - closable popup
    public var isPopup: Bool {
        return updateType == 2
    }
    
    /// Whether update type is popup force (3) - non-closable popup with skip attempts
    public var isPopupForce: Bool {
        return updateType == 3
    }
    
    /// Whether update is mandatory (types 2 or 3 require action)
    public var isMandatory: Bool {
        return updateType == 2 || updateType == 3
    }
    
    /// Whether update is optional (types 0 or 1)
    public var isOptional: Bool {
        return updateType == 0 || updateType == 1
    }
    
    /// Primary download URL
    public var primaryDownloadUrl: String? {
        return appUrl ?? appDeeplink
    }
}


/// Update type enumeration
public enum UpdateType: String, Codable, CaseIterable {
    case none = "none"
    case patch = "patch"
    case minor = "minor"
    case major = "major"
    case critical = "critical"
    
    /// Priority for sorting
    public var priority: Int {
        switch self {
        case .none:
            return 0
        case .patch:
            return 1
        case .minor:
            return 2
        case .major:
            return 3
        case .critical:
            return 4
        }
    }
    
    /// Display name
    public var displayName: String {
        switch self {
        case .none:
            return "No Update"
        case .patch:
            return "Patch"
        case .minor:
            return "Minor"
        case .major:
            return "Major"
        case .critical:
            return "Critical"
        }
    }
}

/// Update check response
public struct UpdateCheckResponse {
    public let hasUpdate: Bool
    public let updateInfo: UpdateInfo?
    public let maintenanceMode: Bool
    public let maintenanceMessage: String?
    
    public init(
        hasUpdate: Bool,
        updateInfo: UpdateInfo?,
        maintenanceMode: Bool = false,
        maintenanceMessage: String? = nil
    ) {
        self.hasUpdate = hasUpdate
        self.updateInfo = updateInfo
        self.maintenanceMode = maintenanceMode
        self.maintenanceMessage = maintenanceMessage
    }
}


/// Analytics event for tracking
public struct AnalyticsEvent: Codable {
    public let name: String
    public let properties: [String: String]
    public let timestamp: Date
    
    public init(
        name: String,
        properties: [String: String] = [:],
        timestamp: Date = Date()
    ) {
        self.name = name
        self.properties = properties
        self.timestamp = timestamp
    }
}

/// AnyCodable for handling dynamic JSON values
public struct AnyCodable: Codable {
    public let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
}
