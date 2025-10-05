//
//  Changelog.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation

/// Represents a changelog for releases
public struct Changelog: Codable, Identifiable, Equatable {

    // MARK: - Properties

    /// Unique identifier for the changelog
    public let id: String

    /// Associated release ID
    public let releaseId: String

    /// Changelog title
    public let title: String

    /// Detailed changelog content
    public let content: String

    /// List of changelog entries
    public let entries: [ChangelogEntry]

    /// Changelog categories
    public let categories: [ChangelogCategory]

    /// Author information
    public let author: Author?

    /// Creation date
    public let createdAt: Date

    /// Last update date
    public let updatedAt: Date

    /// Publication date
    public let publishedAt: Date?

    /// Locale/language of the changelog
    public let locale: String

    /// Whether changelog is public
    public let isPublic: Bool

    // MARK: - Computed Properties

    /// Formatted creation date
    public var formattedCreationDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }

    /// Changelog summary (first 200 characters)
    public var summary: String {
        if content.count <= 200 {
            return content
        }
        let endIndex = content.index(content.startIndex, offsetBy: 200)
        return String(content[..<endIndex]) + "..."
    }

    /// Grouped entries by category
    public var entriesByCategory: [ChangelogCategory: [ChangelogEntry]] {
        return Dictionary(grouping: entries) { $0.category }
    }

    /// Number of entries in each category
    public var entryCountsByCategory: [ChangelogCategory: Int] {
        var counts: [ChangelogCategory: Int] = [:]
        for entry in entries {
            counts[entry.category, default: 0] += 1
        }
        return counts
    }

    // MARK: - Initialization

    public init(
        id: String,
        releaseId: String,
        title: String,
        content: String,
        entries: [ChangelogEntry],
        categories: [ChangelogCategory] = [],
        author: Author? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        publishedAt: Date? = nil,
        locale: String = "en",
        isPublic: Bool = true
    ) {
        self.id = id
        self.releaseId = releaseId
        self.title = title
        self.content = content
        self.entries = entries
        self.categories = categories.isEmpty ? Array(Set(entries.map { $0.category })) : categories
        self.author = author
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.publishedAt = publishedAt
        self.locale = locale
        self.isPublic = isPublic
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case id
        case releaseId = "release_id"
        case title
        case content
        case entries
        case categories
        case author
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
        case locale
        case isPublic = "is_public"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Handle date decoding with multiple formats
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        id = try container.decode(String.self, forKey: .id)
        releaseId = try container.decode(String.self, forKey: .releaseId)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        entries = try container.decode([ChangelogEntry].self, forKey: .entries)
        categories = try container.decodeIfPresent([ChangelogCategory].self, forKey: .categories) ?? []
        author = try container.decodeIfPresent(Author.self, forKey: .author)

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

        if let dateString = try? container.decodeIfPresent(String.self, forKey: .publishedAt) {
            publishedAt = dateString.isEmpty ? nil : dateFormatter.date(from: dateString)
        } else {
            publishedAt = try container.decodeIfPresent(Date.self, forKey: .publishedAt)
        }

        locale = try container.decodeIfPresent(String.self, forKey: .locale) ?? "en"
        isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic) ?? true
    }
}

/// Individual changelog entry
public struct ChangelogEntry: Codable, Identifiable, Equatable {

    // MARK: - Properties

    /// Unique identifier
    public let id: String

    /// Entry title (optional)
    public let title: String?

    /// Entry description
    public let description: String

    /// Category of the entry
    public let category: ChangelogCategory

    /// Priority of the entry
    public let priority: EntryPriority

    /// Tags associated with the entry
    public let tags: [String]

    /// Whether this is a breaking change
    public let isBreaking: Bool

    // MARK: - Computed Properties

    /// Display title or first line of description
    public var displayTitle: String {
        return title ?? description.components(separatedBy: .newlines).first ?? ""
    }

    // MARK: - Initialization

    public init(
        id: String = UUID().uuidString,
        title: String? = nil,
        description: String,
        category: ChangelogCategory,
        priority: EntryPriority = .normal,
        tags: [String] = [],
        isBreaking: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.priority = priority
        self.tags = tags
        self.isBreaking = isBreaking
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case category
        case priority
        case tags
        case isBreaking = "is_breaking"
    }
}

/// Changelog categories
public enum ChangelogCategory: String, Codable, CaseIterable {
    case feature = "feature"
    case improvement = "improvement"
    case bugfix = "bugfix"
    case security = "security"
    case performance = "performance"
    case ui = "ui"
    case api = "api"
    case documentation = "documentation"
    case other = "other"

    /// Display name
    public var displayName: String {
        switch self {
        case .feature:
            return "Features"
        case .improvement:
            return "Improvements"
        case .bugfix:
            return "Bug Fixes"
        case .security:
            return "Security"
        case .performance:
            return "Performance"
        case .ui:
            return "UI/UX"
        case .api:
            return "API"
        case .documentation:
            return "Documentation"
        case .other:
            return "Other"
        }
    }

    /// Icon name for the category
    public var iconName: String {
        switch self {
        case .feature:
            return "star.fill"
        case .improvement:
            return "arrow.up.circle.fill"
        case .bugfix:
            return "ladybug.fill"
        case .security:
            return "shield.fill"
        case .performance:
            return "speedometer"
        case .ui:
            return "paintbrush.fill"
        case .api:
            return "network"
        case .documentation:
            return "doc.text.fill"
        case .other:
            return "ellipsis.circle.fill"
        }
    }

    /// Color for the category (deprecated - use categoryColor in ChangelogView instead)
    public var color: String {
        switch self {
        case .feature:
            return "blue"
        case .improvement:
            return "green"
        case .bugfix:
            return "orange"
        case .security:
            return "red"
        case .performance:
            return "purple"
        case .ui:
            return "pink"
        case .api:
            return "indigo"
        case .documentation:
            return "gray"
        case .other:
            return "secondary"
        }
    }
}

/// Entry priority
public enum EntryPriority: String, Codable, CaseIterable {
    case low = "low"
    case normal = "normal"
    case high = "high"
    case critical = "critical"

    /// Sort order
    public var sortOrder: Int {
        switch self {
        case .critical: return 0
        case .high: return 1
        case .normal: return 2
        case .low: return 3
        }
    }

    /// Display name
    public var displayName: String {
        switch self {
        case .critical: return "Critical"
        case .high: return "High"
        case .normal: return "Normal"
        case .low: return "Low"
        }
    }
}

/// Author information
public struct Author: Codable, Equatable {

    // MARK: - Properties

    /// Author name
    public let name: String

    /// Author email
    public let email: String?

    /// Author avatar URL
    public let avatarURL: URL?

    /// Author role/title
    public let role: String?

    // MARK: - Initialization

    public init(
        name: String,
        email: String? = nil,
        avatarURL: URL? = nil,
        role: String? = nil
    ) {
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.role = role
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case name
        case email
        case avatarURL = "avatar_url"
        case role
    }
}

// MARK: - Extensions

extension Changelog {

    /// Get entries filtered by category
    public func entries(in category: ChangelogCategory) -> [ChangelogEntry] {
        return entries.filter { $0.category == category }
    }

    /// Get breaking changes
    public var breakingChanges: [ChangelogEntry] {
        return entries.filter { $0.isBreaking }
    }

    /// Get high priority entries
    public var highPriorityEntries: [ChangelogEntry] {
        return entries.filter { $0.priority == .high || $0.priority == .critical }
    }

    /// Check if changelog has content in any category
    public func hasContent(in category: ChangelogCategory) -> Bool {
        return entries.contains { $0.category == category }
    }

    /// Get sorted categories by entry count
    public var sortedCategories: [ChangelogCategory] {
        return categories.sorted { category1, category2 in
            let count1 = entries.filter { $0.category == category1 }.count
            let count2 = entries.filter { $0.category == category2 }.count
            return count1 > count2
        }
    }
}