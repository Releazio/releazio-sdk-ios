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

}