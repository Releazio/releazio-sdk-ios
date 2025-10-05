//
//  NetworkClient.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation

/// Protocol for network client implementation
public protocol NetworkClientProtocol {
    func request<T: Codable>(_ request: APIRequest) async throws -> T
    func requestWithPagination<T: Codable>(_ request: APIRequest) async throws -> (data: [T], pagination: PaginationInfo?)
}

/// Network client for making API requests
public class NetworkClient: NetworkClientProtocol {

    // MARK: - Properties

    /// Configuration for the network client
    private let configuration: ReleazioConfiguration

    /// URLSession for making requests
    private let session: URLSession

    // MARK: - Initialization

    /// Initialize network client with configuration
    /// - Parameter configuration: Releazio configuration
    init(configuration: ReleazioConfiguration) {
        self.configuration = configuration

        // Create custom session configuration
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = configuration.networkTimeout
        sessionConfiguration.timeoutIntervalForResource = configuration.networkTimeout * 2
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData

        // Create session
        self.session = URLSession(configuration: sessionConfiguration)
    }

    // MARK: - Public Methods

    /// Make a request with custom APIRequest
    /// - Parameter request: API request configuration
    /// - Returns: Decoded response
    /// - Throws: ReleazioError
    public func request<T: Codable>(_ request: APIRequest) async throws -> T {
        return try await executeRequest(request)
    }

    /// Make a request expecting paginated response
    /// - Parameter request: API request configuration
    /// - Returns: Tuple with data and pagination info
    /// - Throws: ReleazioError
    public func requestWithPagination<T: Codable>(_ request: APIRequest) async throws -> (data: [T], pagination: PaginationInfo?) {
        let response: ArrayAPIResponse<T> = try await executeRequest(request)
        return (response.data ?? [], response.meta?.pagination)
    }

    // MARK: - Private Methods

    /// Execute the actual network request
    /// - Parameter request: API request to execute
    /// - Returns: Decoded response
    /// - Throws: ReleazioError
    private func executeRequest<T: Codable>(_ request: APIRequest) async throws -> T {
        // Create URLRequest
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = request.timeout
        
        // Add headers
        for (key, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add body if present
        if let body = request.body {
            urlRequest.httpBody = body
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        do {
            let (data, response) = try await session.data(for: urlRequest)

            // Validate response
            try validateResponse(response, data: data)

            // Decode response
            let decoder = JSONDecoder()
            let result = try decoder.decode(T.self, from: data)
            return result

        } catch {
            var data: Data?
            var response: URLResponse?

            // Try to extract data and response from the error if possible
            if let urlError = error as? URLError {
                data = nil
                response = nil
            }

            throw processError(error, response: response, data: data)
        }
    }

    /// Validate HTTP response
    /// - Parameters:
    ///   - response: HTTP response
    ///   - data: Response data
    /// - Throws: ReleazioError
    private func validateResponse(_ response: URLResponse?, data: Data?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ReleazioError.invalidResponse
        }
        
        // Check status code
        switch httpResponse.statusCode {
        case 200...299:
            break // Success
        case 401:
            throw ReleazioError.invalidApiKey
        case 403:
            throw ReleazioError.apiError(code: "FORBIDDEN", message: "Access forbidden")
        case 404:
            throw ReleazioError.apiError(code: "NOT_FOUND", message: "Resource not found")
        case 429:
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                .flatMap(Int.init)
                .map(TimeInterval.init)
            throw ReleazioError.rateLimitExceeded(retryAfter: retryAfter)
        case 500...599:
            let message = String(data: data ?? Data(), encoding: .utf8)
            throw ReleazioError.serverError(statusCode: httpResponse.statusCode, message: message)
        default:
            let message = String(data: data ?? Data(), encoding: .utf8)
            throw ReleazioError.apiError(code: "HTTP_ERROR", message: message)
        }
        
        // Validate content type
        if let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") {
            guard contentType.contains("application/json") else {
                throw ReleazioError.apiError(
                    code: "INVALID_CONTENT_TYPE",
                    message: "Expected JSON, got \(contentType)"
                )
            }
        }
    }

    /// Process network error and convert to ReleazioError
    /// - Parameters:
    ///   - error: Original error
    ///   - response: HTTP response
    ///   - data: Response data
    /// - Returns: ReleazioError
    private func processError(_ error: Error, response: URLResponse?, data: Data?) -> ReleazioError {
        // Log error if debug mode is enabled
        if configuration.debugLoggingEnabled {
            print("🚨 Releazio Network Error: \(error)")
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Response: \(httpResponse.statusCode)")
            }
        }

        // Check for URL errors
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return .noInternetConnection
            case .timedOut:
                return .requestTimeout
            case .badURL:
                return .invalidURL(urlError.localizedDescription)
            case .cancelled:
                return .cancelled
            default:
                return .networkError(urlError)
            }
        }

        // Check for decoding errors
        if error is DecodingError {
            return .decodingError(error)
        }

        return .networkError(error)
    }

    /// Get default headers for all requests
    /// - Returns: Default headers dictionary
    private func defaultHeaders() -> [String: String] {
        var headers: [String: String] = [
            "Accept": "application/json",
            "User-Agent": "Releazio-iOS-SDK/1.0.0",
            "X-SDK-Version": "1.0.0",
            "X-Platform": "iOS",
            "X-OS-Version": ProcessInfo.processInfo.operatingSystemVersionString,
            "X-App-Version": Bundle.main.appVersion?.versionString ?? "unknown",
            "X-App-Build": Bundle.main.buildVersion ?? "unknown"
        ]

        // Add API key if available
        headers["Authorization"] = "Bearer \(configuration.apiKey)"

        return headers
    }
}

// MARK: - NetworkClient Extensions

extension URL {
    /// Create URL by appending path to base URL
    /// - Parameter baseURL: Base URL
    /// - Returns: Full URL
    func url(with baseURL: URL) -> URL {
        if self.scheme != nil {
            return self // Already a full URL
        }

        let components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        var newComponents = components
        newComponents?.path = (components?.path ?? "") + (self.path)

        return newComponents?.url ?? self
    }
}

