//
//  Release.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation

/// Represents an application release
public struct Release: Codable, Identifiable, Equatable {

    // MARK: - Properties

    /// Unique identifier for the release
    public let id: String

    /// Release version number (semantic versioning)
    public let version: String

    /// Build number
    public let buildNumber: String?

    /// Release title
    public let title: String

    /// Detailed release description
    public let description: String?

    /// Release notes
    public let releaseNotes: String?

    /// Release date
    public let releaseDate: Date

    /// Publication date (when it was made public)
    public let publishedAt: Date?

    /// Indicates if this is a mandatory update
    public let isMandatory: Bool

    /// Indicates if the release is currently active
    public let isActive: Bool

    /// Minimum required iOS version
    public let minimumOSVersion: String?

    /// Download URL for the release
    public let downloadURL: String?

    /// App Store URL (if applicable)
    public let appStoreURL: URL?

    /// Size of the update in bytes
    public let updateSize: Int64?

    /// Release status
    public let status: ReleaseStatus

    /// Environment for this release
    public let environment: String

    /// Tags associated with the release
    public let tags: [String]

    /// Metadata for the release
    public let metadata: [String: String]?

    /// Creation timestamp
    public let createdAt: Date

    /// Last update timestamp
    public let updatedAt: Date

    // MARK: - Computed Properties

    /// Formatted version string with build number if available
    public var versionWithBuild: String {
        if let buildNumber = buildNumber {
            return "\(version) (\(buildNumber))"
        }
        return version
    }

    /// Formatted release date
    public var formattedReleaseDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: releaseDate)
    }

    /// Indicates if this release is newer than current app version
    public var isNewerThanCurrent: Bool {
        guard let currentVersion = Bundle.main.appVersion else {
            return false
        }
        guard let releaseVersion = try? AppVersion(versionString: version) else {
            return false
        }
        return releaseVersion > currentVersion
    }

    /// Release priority for UI display
    public var priority: ReleasePriority {
        if isMandatory {
            return .critical
        } else if status == .beta {
            return .beta
        } else {
            return .normal
        }
    }

    // MARK: - Initialization

    public init(
        id: String,
        version: String,
        buildNumber: String? = nil,
        title: String,
        description: String? = nil,
        releaseNotes: String? = nil,
        releaseDate: Date,
        publishedAt: Date? = nil,
        isMandatory: Bool = false,
        isActive: Bool = true,
        minimumOSVersion: String? = nil,
        downloadURL: String? = nil,
        appStoreURL: URL? = nil,
        updateSize: Int64? = nil,
        status: ReleaseStatus = .published,
        environment: String = "production",
        tags: [String] = [],
        metadata: [String: String]? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.version = version
        self.buildNumber = buildNumber
        self.title = title
        self.description = description
        self.releaseNotes = releaseNotes
        self.releaseDate = releaseDate
        self.publishedAt = publishedAt
        self.isMandatory = isMandatory
        self.isActive = isActive
        self.minimumOSVersion = minimumOSVersion
        self.downloadURL = downloadURL
        self.appStoreURL = appStoreURL
        self.updateSize = updateSize
        self.status = status
        self.environment = environment
        self.tags = tags
        self.metadata = metadata
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case id
        case version
        case buildNumber = "build_number"
        case title
        case description
        case releaseNotes = "release_notes"
        case releaseDate = "release_date"
        case publishedAt = "published_at"
        case isMandatory = "is_mandatory"
        case isActive = "is_active"
        case minimumOSVersion = "minimum_os_version"
        case downloadURL = "download_url"
        case appStoreURL = "app_store_url"
        case updateSize = "update_size"
        case status
        case environment
        case tags
        case metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Handle date decoding with multiple formats
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        id = try container.decode(String.self, forKey: .id)
        version = try container.decode(String.self, forKey: .version)
        buildNumber = try container.decodeIfPresent(String.self, forKey: .buildNumber)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        releaseNotes = try container.decodeIfPresent(String.self, forKey: .releaseNotes)

        // Try to decode dates with ISO8601 format first, then fallback to timestamp
        if let dateString = try? container.decode(String.self, forKey: .releaseDate) {
            releaseDate = dateFormatter.date(from: dateString) ?? Date()
        } else {
            releaseDate = try container.decode(Date.self, forKey: .releaseDate)
        }

        if let dateString = try? container.decodeIfPresent(String.self, forKey: .publishedAt) {
            publishedAt = dateString.isEmpty ? nil : dateFormatter.date(from: dateString)
        } else {
            publishedAt = try container.decodeIfPresent(Date.self, forKey: .publishedAt)
        }

        isMandatory = try container.decodeIfPresent(Bool.self, forKey: .isMandatory) ?? false
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
        minimumOSVersion = try container.decodeIfPresent(String.self, forKey: .minimumOSVersion)
        downloadURL = try container.decodeIfPresent(String.self, forKey: .downloadURL)
        appStoreURL = try container.decodeIfPresent(URL.self, forKey: .appStoreURL)
        updateSize = try container.decodeIfPresent(Int64.self, forKey: .updateSize)
        status = try container.decodeIfPresent(ReleaseStatus.self, forKey: .status) ?? .published
        environment = try container.decodeIfPresent(String.self, forKey: .environment) ?? "production"
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        metadata = try container.decodeIfPresent([String: String].self, forKey: .metadata)

        if let dateString = try? container.decodeIfPresent(String.self, forKey: .createdAt) {
            createdAt = dateFormatter.date(from: dateString) ?? Date()
        } else {
            createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        }

        if let dateString = try? container.decodeIfPresent(String.self, forKey: .updatedAt) {
            updatedAt = dateFormatter.date(from: dateString) ?? Date()
        } else {
            updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
        }
    }
}

// MARK: - Supporting Enums

/// Release status
public enum ReleaseStatus: String, Codable, CaseIterable {
    case draft = "draft"
    case beta = "beta"
    case published = "published"
    case archived = "archived"

    /// Display name for the status
    public var displayName: String {
        switch self {
        case .draft:
            return "Draft"
        case .beta:
            return "Beta"
        case .published:
            return "Published"
        case .archived:
            return "Archived"
        }
    }

    /// Indicates if the release is publicly available
    public var isPubliclyAvailable: Bool {
        return self == .published
    }
}

/// Release priority for UI ordering
public enum ReleasePriority: Int, CaseIterable {
    case critical = 0  // Mandatory updates
    case normal = 1    // Regular updates
    case beta = 2      // Beta versions
}

// MARK: - Extensions

extension Release {

    /// Check if this release is compatible with current OS version
    public var isCompatibleWithCurrentOS: Bool {
        guard let minimumOSVersion = minimumOSVersion else { return true }

        let currentOSVersion = ProcessInfo.processInfo.operatingSystemVersion
        let currentVersionString = "\(currentOSVersion.majorVersion).\(currentOSVersion.minorVersion).\(currentOSVersion.patchVersion)"

        return currentVersionString >= minimumOSVersion
    }

    /// Get formatted update size
    public var formattedUpdateSize: String? {
        guard let updateSize = updateSize else { return nil }

        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useKB, .useMB, .useGB]
        byteCountFormatter.countStyle = .file
        return byteCountFormatter.string(fromByteCount: updateSize)
    }

    /// Check if release has download URL
    public var hasDownloadURL: Bool {
        return downloadURL != nil || appStoreURL != nil
    }

    /// Get primary download URL
    public var primaryDownloadURL: URL? {
        if let appStoreURL = appStoreURL {
            return appStoreURL
        }
        if let downloadURLString = downloadURL {
            return URL(string: downloadURLString)
        }
        return nil
    }
}