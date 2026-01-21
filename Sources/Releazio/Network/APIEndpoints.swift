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
    /// - Parameters:
    ///   - channel: Distribution channel (e.g., "appstore")
    ///   - appId: Application bundle identifier
    ///   - appVersionCode: Application build version (CFBundleVersion)
    ///   - appVersionName: Application version name (CFBundleShortVersionString)
    ///   - phoneLocaleCountry: User's locale country code
    ///   - phoneLocaleLanguage: User's locale language code
    ///   - osVersionCode: OS version code (major version number)
    ///   - deviceManufacturer: Device manufacturer
    ///   - deviceBrand: Device brand
    ///   - deviceModel: Device model
    /// - Returns: Endpoint URL with query parameters
    public static func getConfig(
        channel: String,
        appId: String?,
        appVersionCode: String?,
        appVersionName: String?,
        phoneLocaleCountry: String?,
        phoneLocaleLanguage: String?,
        osVersionCode: Int?,
        deviceManufacturer: String,
        deviceBrand: String,
        deviceModel: String?
    ) -> URL {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        
        var queryItems: [URLQueryItem] = []
        
        // Required parameters
        queryItems.append(URLQueryItem(name: "channel", value: channel))
        
        // Optional parameters - only add if not nil
        if let appId = appId {
            queryItems.append(URLQueryItem(name: "app_id", value: appId))
        }
        if let appVersionCode = appVersionCode {
            queryItems.append(URLQueryItem(name: "app_version_code", value: appVersionCode))
        }
        if let appVersionName = appVersionName {
            queryItems.append(URLQueryItem(name: "app_version_name", value: appVersionName))
        }
        if let phoneLocaleCountry = phoneLocaleCountry {
            queryItems.append(URLQueryItem(name: "phone_locale_country", value: phoneLocaleCountry))
        }
        if let phoneLocaleLanguage = phoneLocaleLanguage {
            queryItems.append(URLQueryItem(name: "phone_locale_language", value: phoneLocaleLanguage))
        }
        if let osVersionCode = osVersionCode {
            queryItems.append(URLQueryItem(name: "os_version_code", value: String(osVersionCode)))
        }
        queryItems.append(URLQueryItem(name: "device_manufacturer", value: deviceManufacturer))
        queryItems.append(URLQueryItem(name: "device_brand", value: deviceBrand))
        if let deviceModel = deviceModel {
            queryItems.append(URLQueryItem(name: "device_model", value: deviceModel))
        }
        
        components.queryItems = queryItems
        
        return components.url ?? baseURL
    }
    
    /// Device initialization endpoint
    /// - Returns: Endpoint URL for /init
    public static func initEndpoint() -> URL {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.path = "/init"
        return components.url ?? baseURL
    }
}

// MARK: - HTTP Methods

public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
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
    
    /// Create POST request with JSON body
    /// - Parameters:
    ///   - url: URL
    ///   - body: JSON body data
    ///   - headers: Additional headers
    ///   - timeout: Request timeout
    /// - Returns: APIRequest
    public static func post(
        url: URL,
        body: Data?,
        headers: [String: String] = [:],
        timeout: TimeInterval = 30
    ) -> APIRequest {
        return APIRequest(
            url: url,
            method: .POST,
            headers: headers,
            body: body,
            timeout: timeout
        )
    }

}