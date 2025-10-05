//
//  AppVersion.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation

/// Represents application version information
public struct AppVersion: Codable, Equatable, Comparable {

    // MARK: - Properties

    /// Major version number
    public let major: Int

    /// Minor version number
    public let minor: Int

    /// Patch version number
    public let patch: Int

    /// Pre-release identifier (e.g., "beta", "alpha")
    public let prerelease: String?

    /// Build metadata
    public let build: String?

    /// Full version string
    public let versionString: String

    // MARK: - Computed Properties

    /// Semantic version string (without prerelease or build)
    public var semanticVersion: String {
        return "\(major).\(minor).\(patch)"
    }

    /// Full version string including prerelease and build
    public var fullVersion: String {
        var version = semanticVersion
        if let prerelease = prerelease {
            version += "-\(prerelease)"
        }
        if let build = build {
            version += "+\(build)"
        }
        return version
    }

    /// Is this a prerelease version
    public var isPrerelease: Bool {
        return prerelease != nil
    }

    /// Is this a stable release
    public var isStable: Bool {
        return prerelease == nil
    }

    // MARK: - Initialization

    /// Initialize with individual version components
    public init(
        major: Int,
        minor: Int,
        patch: Int,
        prerelease: String? = nil,
        build: String? = nil
    ) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.prerelease = prerelease
        self.build = build
        self.versionString = "\(major).\(minor).\(patch)"
    }

    /// Internal initializer that accepts versionString (for decoding)
    internal init(
        major: Int,
        minor: Int,
        patch: Int,
        prerelease: String? = nil,
        build: String? = nil,
        versionString: String
    ) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.prerelease = prerelease
        self.build = build
        self.versionString = versionString
    }

    /// Initialize with version string
    public init(versionString: String) throws {
        self.versionString = versionString

        // Parse semantic version (x.y.z or x.y.z-prerelease+build)
        let pattern = #"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$"#

        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            throw ReleazioError.invalidVersionFormat(versionString)
        }

        let range = NSRange(location: 0, length: versionString.utf16.count)
        guard let match = regex.firstMatch(in: versionString, range: range) else {
            throw ReleazioError.invalidVersionFormat(versionString)
        }

        // Extract components
        if let majorRange = Range(match.range(at: 1), in: versionString),
           let major = Int(versionString[majorRange]) {
            self.major = major
        } else {
            throw ReleazioError.invalidVersionFormat(versionString)
        }

        if let minorRange = Range(match.range(at: 2), in: versionString),
           let minor = Int(versionString[minorRange]) {
            self.minor = minor
        } else {
            throw ReleazioError.invalidVersionFormat(versionString)
        }

        if let patchRange = Range(match.range(at: 3), in: versionString),
           let patch = Int(versionString[patchRange]) {
            self.patch = patch
        } else {
            throw ReleazioError.invalidVersionFormat(versionString)
        }

        // Extract prerelease if present
        if let prereleaseRange = Range(match.range(at: 4), in: versionString) {
            self.prerelease = String(versionString[prereleaseRange])
        } else {
            self.prerelease = nil
        }

        // Extract build if present
        if let buildRange = Range(match.range(at: 5), in: versionString) {
            self.build = String(versionString[buildRange])
        } else {
            self.build = nil
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case major
        case minor
        case patch
        case prerelease
        case build
        case versionString = "version_string"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Try to decode as individual components first
        if container.contains(.major) {
            let decodedMajor = try container.decode(Int.self, forKey: .major)
            let decodedMinor = try container.decode(Int.self, forKey: .minor)
            let decodedPatch = try container.decode(Int.self, forKey: .patch)
            let decodedPrerelease = try container.decodeIfPresent(String.self, forKey: .prerelease)
            let decodedBuild = try container.decodeIfPresent(String.self, forKey: .build)
            let decodedVersionString = try container.decodeIfPresent(String.self, forKey: .versionString) ?? "\(decodedMajor).\(decodedMinor).\(decodedPatch)"

            self.init(
                major: decodedMajor,
                minor: decodedMinor,
                patch: decodedPatch,
                prerelease: decodedPrerelease,
                build: decodedBuild,
                versionString: decodedVersionString
            )
        } else {
            // Try to decode as version string
            let version = try container.decode(String.self, forKey: .versionString)
            try self.init(versionString: version)
        }
    }

    // MARK: - Comparable

    public static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        // Compare major, minor, patch versions
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }

        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }

        if lhs.patch != rhs.patch {
            return lhs.patch < rhs.patch
        }

        // Compare prerelease versions
        switch (lhs.prerelease, rhs.prerelease) {
        case (nil, nil):
            return false // Both are stable versions
        case (nil, _):
            return false // Stable version > prerelease
        case (_, nil):
            return true // Prerelease < stable version
        case (let lhsPre?, let rhsPre?):
            // Compare prerelease identifiers
            return lhsPre.compare(rhsPre, options: .numeric) == .orderedAscending
        }
    }

    public static func == (lhs: AppVersion, rhs: AppVersion) -> Bool {
        return lhs.major == rhs.major &&
               lhs.minor == rhs.minor &&
               lhs.patch == rhs.patch &&
               lhs.prerelease == rhs.prerelease
    }

    // MARK: - Operators

    public static func <= (lhs: AppVersion, rhs: AppVersion) -> Bool {
        return lhs < rhs || lhs == rhs
    }

    public static func >= (lhs: AppVersion, rhs: AppVersion) -> Bool {
        return !(lhs < rhs)
    }

    public static func > (lhs: AppVersion, rhs: AppVersion) -> Bool {
        return rhs < lhs
    }
}

// MARK: - String + AppVersion Conversion

extension String {

    /// Convert string to AppVersion
    /// - Returns: AppVersion if valid, nil otherwise
    public var asAppVersion: AppVersion? {
        return try? AppVersion(versionString: self)
    }

    /// Check if string is a valid version
    public var isValidVersion: Bool {
        return asAppVersion != nil
    }
}

// MARK: - AppVersion + Bundle

extension Bundle {

    /// Get current app version as AppVersion
    public var appVersion: AppVersion? {
        guard let versionString = infoDictionary?["CFBundleShortVersionString"] as? String else {
            return nil
        }
        return try? AppVersion(versionString: versionString)
    }

    /// Get current app build version
    public var buildVersion: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

// MARK: - AppVersion Extensions

extension AppVersion {

    /// Check if this version is compatible with minimum required version
    /// - Parameter minimumVersion: Minimum required version
    /// - Returns: True if compatible
    public func isCompatible(with minimumVersion: AppVersion) -> Bool {
        return self >= minimumVersion
    }

    /// Get version bump type compared to another version
    /// - Parameter other: Other version to compare with
    /// - Returns: Version bump type
    public func bumpType(comparedTo other: AppVersion) -> VersionBumpType {
        if self.major > other.major {
            return .major
        } else if self.minor > other.minor {
            return .minor
        } else if self.patch > other.patch {
            return .patch
        } else {
            return .none
        }
    }

    /// Check if this is a significant update (major or minor)
    public var isSignificantUpdate: Bool {
        return major > 0 || minor > 0
    }
}

/// Version bump type
public enum VersionBumpType {
    case none
    case patch
    case minor
    case major

    /// Display name
    public var displayName: String {
        switch self {
        case .none:
            return "No change"
        case .patch:
            return "Patch"
        case .minor:
            return "Minor"
        case .major:
            return "Major"
        }
    }

    /// Description
    public var description: String {
        switch self {
        case .none:
            return "No version change"
        case .patch:
            return "Bug fixes and improvements"
        case .minor:
            return "New features and improvements"
        case .major:
            return "Major update with breaking changes"
        }
    }
}