//
//  APIResponse.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation

/// Generic API response wrapper
public struct APIResponse<T: Codable>: Codable {

    // MARK: - Properties

    /// Response data
    public let data: T?

    /// Success status
    public let success: Bool

    /// Response message
    public let message: String?

    /// Error information
    public let error: APIError?

    /// Metadata (pagination, etc.)
    public let meta: APIMetadata?

    /// Response timestamp
    public let timestamp: Date

    /// Request ID for tracking
    public let requestId: String?

    // MARK: - Computed Properties

    /// Check if response is successful
    public var isSuccess: Bool {
        return success && error == nil
    }

    /// Get error or nil if successful
    public var responseError: ReleazioError? {
        guard let error = error else { return nil }
        return .apiError(code: error.code, message: error.message)
    }

    // MARK: - Initialization

    public init(
        data: T? = nil,
        success: Bool = true,
        message: String? = nil,
        error: APIError? = nil,
        meta: APIMetadata? = nil,
        timestamp: Date = Date(),
        requestId: String? = nil
    ) {
        self.data = data
        self.success = success
        self.message = message
        self.error = error
        self.meta = meta
        self.timestamp = timestamp
        self.requestId = requestId
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case data
        case success
        case message
        case error
        case meta
        case timestamp
        case requestId = "request_id"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Handle date decoding with multiple formats
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        data = try container.decodeIfPresent(T.self, forKey: .data)
        success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? true
        message = try container.decodeIfPresent(String.self, forKey: .message)
        error = try container.decodeIfPresent(APIError.self, forKey: .error)
        meta = try container.decodeIfPresent(APIMetadata.self, forKey: .meta)

        if let dateString = try? container.decodeIfPresent(String.self, forKey: .timestamp) {
            timestamp = dateFormatter.date(from: dateString) ?? Date()
        } else {
            timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date()
        }

        requestId = try container.decodeIfPresent(String.self, forKey: .requestId)
    }
}

/// API error information
public struct APIError: Codable, Equatable {

    // MARK: - Properties

    /// Error code
    public let code: String

    /// Error message
    public let message: String

    /// Error details
    public let details: [String]?

    /// Error type
    public let type: ErrorType?

    /// Field name (for validation errors)
    public let field: String?

    // MARK: - Error Types

    public enum ErrorType: String, Codable, CaseIterable {
        case validation = "validation"
        case authentication = "authentication"
        case authorization = "authorization"
        case notFound = "not_found"
        case rateLimit = "rate_limit"
        case server = "server"
        case network = "network"
        case unknown = "unknown"

        /// Display name
        public var displayName: String {
            switch self {
            case .validation: return "Validation Error"
            case .authentication: return "Authentication Error"
            case .authorization: return "Authorization Error"
            case .notFound: return "Not Found"
            case .rateLimit: return "Rate Limit Exceeded"
            case .server: return "Server Error"
            case .network: return "Network Error"
            case .unknown: return "Unknown Error"
            }
        }
    }

    // MARK: - Initialization

    public init(
        code: String,
        message: String,
        details: [String]? = nil,
        type: ErrorType? = nil,
        field: String? = nil
    ) {
        self.code = code
        self.message = message
        self.details = details
        self.type = type
        self.field = field
    }
}

/// API metadata (pagination, etc.)
public struct APIMetadata: Codable, Equatable {

    // MARK: - Pagination Properties

    /// Current page number
    public let page: Int?

    /// Number of items per page
    public let perPage: Int?

    /// Total number of items
    public let total: Int?

    /// Total number of pages
    public let totalPages: Int?

    /// Has next page
    public let hasNextPage: Bool?

    /// Has previous page
    public let hasPreviousPage: Bool?

    // MARK: - Other Properties

    /// API version
    public let apiVersion: String?

    /// Server timestamp
    public let serverTime: Date?

    /// Rate limit information
    public let rateLimit: RateLimitInfo?

    // MARK: - Computed Properties

    /// Pagination information
    public var pagination: PaginationInfo? {
        guard let page = page,
              let perPage = perPage,
              let total = total else { return nil }

        return PaginationInfo(
            page: page,
            perPage: perPage,
            total: total,
            totalPages: totalPages ?? ((total + perPage - 1) / perPage),
            hasNextPage: hasNextPage ?? (page * perPage < total),
            hasPreviousPage: hasPreviousPage ?? (page > 1)
        )
    }

    // MARK: - Initialization

    public init(
        page: Int? = nil,
        perPage: Int? = nil,
        total: Int? = nil,
        totalPages: Int? = nil,
        hasNextPage: Bool? = nil,
        hasPreviousPage: Bool? = nil,
        apiVersion: String? = nil,
        serverTime: Date? = nil,
        rateLimit: RateLimitInfo? = nil
    ) {
        self.page = page
        self.perPage = perPage
        self.total = total
        self.totalPages = totalPages
        self.hasNextPage = hasNextPage
        self.hasPreviousPage = hasPreviousPage
        self.apiVersion = apiVersion
        self.serverTime = serverTime
        self.rateLimit = rateLimit
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case total
        case totalPages = "total_pages"
        case hasNextPage = "has_next_page"
        case hasPreviousPage = "has_previous_page"
        case apiVersion = "api_version"
        case serverTime = "server_time"
        case rateLimit = "rate_limit"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Handle date decoding
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        page = try container.decodeIfPresent(Int.self, forKey: .page)
        perPage = try container.decodeIfPresent(Int.self, forKey: .perPage)
        total = try container.decodeIfPresent(Int.self, forKey: .total)
        totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages)
        hasNextPage = try container.decodeIfPresent(Bool.self, forKey: .hasNextPage)
        hasPreviousPage = try container.decodeIfPresent(Bool.self, forKey: .hasPreviousPage)
        apiVersion = try container.decodeIfPresent(String.self, forKey: .apiVersion)

        if let dateString = try? container.decodeIfPresent(String.self, forKey: .serverTime) {
            serverTime = dateFormatter.date(from: dateString)
        } else {
            serverTime = try container.decodeIfPresent(Date.self, forKey: .serverTime)
        }

        rateLimit = try container.decodeIfPresent(RateLimitInfo.self, forKey: .rateLimit)
    }
}

/// Pagination information
public struct PaginationInfo: Equatable {

    // MARK: - Properties

    public let page: Int
    public let perPage: Int
    public let total: Int
    public let totalPages: Int
    public let hasNextPage: Bool
    public let hasPreviousPage: Bool

    // MARK: - Computed Properties

    /// Start index (1-based)
    public var startIndex: Int {
        return ((page - 1) * perPage) + 1
    }

    /// End index (1-based)
    public var endIndex: Int {
        return min(page * perPage, total)
    }

    /// Items remaining
    public var remainingItems: Int {
        return max(0, total - endIndex)
    }
}

/// Rate limit information
public struct RateLimitInfo: Codable, Equatable {

    // MARK: - Properties

    /// Maximum requests per window
    public let limit: Int

    /// Remaining requests in current window
    public let remaining: Int

    /// When the rate limit window resets (timestamp)
    public let resetTime: Date?

    /// Seconds until reset
    public let resetIn: Int?

    // MARK: - Computed Properties

    /// Is rate limit exceeded
    public var isExceeded: Bool {
        return remaining <= 0
    }

    /// Usage percentage (0-1)
    public var usagePercentage: Double {
        guard limit > 0 else { return 0 }
        return Double(limit - remaining) / Double(limit)
    }

    // MARK: - Initialization

    public init(
        limit: Int,
        remaining: Int,
        resetTime: Date? = nil,
        resetIn: Int? = nil
    ) {
        self.limit = limit
        self.remaining = remaining
        self.resetTime = resetTime
        self.resetIn = resetIn
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case limit
        case remaining
        case resetTime = "reset_time"
        case resetIn = "reset_in"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        limit = try container.decode(Int.self, forKey: .limit)
        remaining = try container.decode(Int.self, forKey: .remaining)

        if let dateString = try? container.decodeIfPresent(String.self, forKey: .resetTime) {
            let dateFormatter = ISO8601DateFormatter()
            resetTime = dateFormatter.date(from: dateString)
        } else {
            resetTime = try container.decodeIfPresent(Date.self, forKey: .resetTime)
        }

        resetIn = try container.decodeIfPresent(Int.self, forKey: .resetIn)
    }
}

// MARK: - Array Response Wrapper

/// Response wrapper for array data with pagination
public typealias ArrayAPIResponse<T: Codable> = APIResponse<[T]>

// MARK: - APIResponse Extensions

extension APIResponse {

    /// Extract data or throw error
    /// - Returns: Response data
    /// - Throws: ReleazioError if response is unsuccessful
    public func unwrap() throws -> T {
        guard let data = data else {
            throw responseError ?? .invalidResponse
        }

        guard isSuccess else {
            throw responseError ?? .invalidResponse
        }

        return data
    }

    /// Extract data with default value
    /// - Parameter defaultValue: Default value if data is nil
    /// - Returns: Response data or default value
    public func data(or defaultValue: T) -> T {
        return data ?? defaultValue
    }
}