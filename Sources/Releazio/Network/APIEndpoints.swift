//
//  APIEndpoints.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation

/// API endpoints for Releazio service
public enum APIEndpoints {

    // MARK: - Base URLs
    
    /// API base URL
    public static let baseURL = URL(string: "https://check.releazio.com")!

    // MARK: - Main Endpoint

    /// Get application configuration and releases
    /// - Returns: Endpoint URL
    public static func getConfig() -> URL {
        return baseURL
    }
}

// MARK: - HTTP Methods

public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

// MARK: - Request Builder

public struct APIRequest {

    public let url: URL
    public let method: HTTPMethod
    public let headers: [String: String]
    public let body: Data?
    public let timeout: TimeInterval

    public init(
        url: URL,
        method: HTTPMethod = .GET,
        headers: [String: String] = [:],
        body: Data? = nil,
        timeout: TimeInterval = 30
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.timeout = timeout
    }
}

// MARK: - APIRequest Extensions

extension APIRequest {

    /// Create GET request
    /// - Parameters:
    ///   - url: URL
    ///   - headers: Additional headers
    ///   - timeout: Request timeout
    /// - Returns: APIRequest
    public static func get(
        url: URL,
        headers: [String: String] = [:],
        timeout: TimeInterval = 30
    ) -> APIRequest {
        return APIRequest(
            url: url,
            method: .GET,
            headers: headers,
            timeout: timeout
        )
    }

    /// Create POST request
    /// - Parameters:
    ///   - url: URL
    ///   - body: Request body
    ///   - headers: Additional headers
    ///   - timeout: Request timeout
    /// - Returns: APIRequest
    public static func post<T: Encodable>(
        url: URL,
        body: T,
        headers: [String: String] = [:],
        timeout: TimeInterval = 30
    ) throws -> APIRequest {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(body)

        var finalHeaders = headers
        finalHeaders["Content-Type"] = "application/json"

        return APIRequest(
            url: url,
            method: .POST,
            headers: finalHeaders,
            body: data,
            timeout: timeout
        )
    }

    /// Create POST request with raw data
    /// - Parameters:
    ///   - url: URL
    ///   - data: Raw data
    ///   - contentType: Content type header
    ///   - headers: Additional headers
    ///   - timeout: Request timeout
    /// - Returns: APIRequest
    public static func post(
        url: URL,
        data: Data,
        contentType: String = "application/json",
        headers: [String: String] = [:],
        timeout: TimeInterval = 30
    ) -> APIRequest {
        var finalHeaders = headers
        finalHeaders["Content-Type"] = contentType

        return APIRequest(
            url: url,
            method: .POST,
            headers: finalHeaders,
            body: data,
            timeout: timeout
        )
    }
}