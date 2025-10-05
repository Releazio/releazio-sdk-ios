//
//  ReleazioError.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import Foundation

/// Custom error types for Releazio SDK
public enum ReleazioError: Error, LocalizedError, Equatable {

    // MARK: - Configuration Errors

    /// SDK is not configured
    case configurationMissing

    /// Invalid API key
    case invalidApiKey

    /// Invalid application ID
    case invalidApplicationId

    /// Invalid configuration parameters
    case invalidConfiguration(String)

    // MARK: - Network Errors

    /// Network request failed
    case networkError(Error)

    /// Invalid URL
    case invalidURL(String)

    /// Request timeout
    case requestTimeout

    /// No internet connection
    case noInternetConnection

    /// Request was cancelled
    case cancelled

    /// Server error with status code
    case serverError(statusCode: Int, message: String?)

    /// Rate limit exceeded
    case rateLimitExceeded(retryAfter: TimeInterval?)

    // MARK: - API Response Errors

    /// Invalid API response
    case invalidResponse

    /// API returned error
    case apiError(code: String, message: String?)

    /// Missing required data in response
    case missingData(String)

    /// Failed to decode JSON response
    case decodingError(Error)

    // MARK: - Cache Errors

    /// Cache operation failed
    case cacheError(Error)

    /// Data not found in cache
    case cacheMiss

    // MARK: - UI Errors

    /// Failed to present UI
    case uiPresentationError

    /// Missing window/scene context
    case missingUIContext

    // MARK: - Validation Errors

    /// Invalid version format
    case invalidVersionFormat(String)

    /// Version comparison failed
    case versionComparisonError

    // MARK: - Public Properties

    public var errorDescription: String? {
        switch self {
        case .configurationMissing:
            return "Releazio SDK is not configured. Call Releazio.configure(with:) first."
        case .invalidApiKey:
            return "Invalid API key provided."
        case .invalidApplicationId:
            return "Invalid application ID provided."
        case .invalidConfiguration(let message):
            return "Invalid configuration: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .requestTimeout:
            return "Request timed out."
        case .noInternetConnection:
            return "No internet connection available."
        case .cancelled:
            return "Request was cancelled."
        case .serverError(let statusCode, let message):
            if let message = message {
                return "Server error \(statusCode): \(message)"
            } else {
                return "Server error with status code: \(statusCode)"
            }
        case .rateLimitExceeded(let retryAfter):
            if let retryAfter = retryAfter {
                return "Rate limit exceeded. Retry after \(Int(retryAfter)) seconds."
            } else {
                return "Rate limit exceeded."
            }
        case .invalidResponse:
            return "Invalid API response received."
        case .apiError(let code, let message):
            if let message = message {
                return "API error (\(code)): \(message)"
            } else {
                return "API error with code: \(code)"
            }
        case .missingData(let data):
            return "Missing required data in response: \(data)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .cacheError(let error):
            return "Cache error: \(error.localizedDescription)"
        case .cacheMiss:
            return "Requested data not found in cache."
        case .uiPresentationError:
            return "Failed to present UI component."
        case .missingUIContext:
            return "No window/scene context available for UI presentation."
        case .invalidVersionFormat(let version):
            return "Invalid version format: \(version)"
        case .versionComparisonError:
            return "Failed to compare app versions."
        }
    }

    public var failureReason: String? {
        switch self {
        case .configurationMissing:
            return "SDK must be configured before making API calls."
        case .invalidApiKey:
            return "The provided API key is not valid or has expired."
        case .invalidApplicationId:
            return "The application ID is not valid or doesn't exist."
        case .invalidConfiguration:
            return "One or more configuration parameters are invalid."
        case .networkError:
            return "Unable to complete network request."
        case .invalidURL:
            return "The URL format is invalid."
        case .requestTimeout:
            return "The network request took too long to complete."
        case .noInternetConnection:
            return "Device is not connected to the internet."
        case .cancelled:
            return "The network request was cancelled."
        case .serverError:
            return "The server returned an error response."
        case .rateLimitExceeded:
            return "Too many requests have been made to the API."
        case .invalidResponse:
            return "The API response format is invalid."
        case .apiError:
            return "The API returned an error response."
        case .missingData:
            return "Expected data is missing from the API response."
        case .decodingError:
            return "Failed to parse the API response."
        case .cacheError:
            return "An error occurred while accessing the cache."
        case .cacheMiss:
            return "The requested data is not available in the cache."
        case .uiPresentationError:
            return "Unable to present the UI component."
        case .missingUIContext:
            return "No valid UI context is available."
        case .invalidVersionFormat:
            return "The version string format is invalid."
        case .versionComparisonError:
            return "Unable to compare version strings."
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .configurationMissing:
            return "Configure the SDK with Releazio.configure(with:) before use."
        case .invalidApiKey:
            return "Check your API key and ensure it's valid for the current environment."
        case .invalidApplicationId:
            return "Verify the application ID in your Releazio dashboard."
        case .invalidConfiguration:
            return "Review and fix the configuration parameters."
        case .networkError, .noInternetConnection:
            return "Check your internet connection and try again."
        case .cancelled:
            return "Retry the request if needed."
        case .requestTimeout:
            return "Try again with a better connection or increase timeout."
        case .serverError:
            return "Try again later or contact support if the issue persists."
        case .rateLimitExceeded:
            return "Wait before making additional requests."
        case .invalidResponse, .apiError, .decodingError:
            return "Report this issue to the Releazio support team."
        case .missingData:
            return "Check if the requested resource exists."
        case .cacheError:
            return "Clear the cache and try again."
        case .cacheMiss:
            return "The data will be fetched from the server."
        case .uiPresentationError, .missingUIContext:
            return "Ensure you're calling from a valid UI context."
        case .invalidVersionFormat:
            return "Use semantic versioning format (e.g., 1.2.3)."
        case .versionComparisonError:
            return "Ensure version strings follow semantic versioning."
        case .invalidURL(let url):
            return "Check the URL format: \(url)"
        }
    }

    // MARK: - Equatable Implementation

    public static func == (lhs: ReleazioError, rhs: ReleazioError) -> Bool {
        switch (lhs, rhs) {
        case (.configurationMissing, .configurationMissing),
             (.invalidApiKey, .invalidApiKey),
             (.invalidApplicationId, .invalidApplicationId),
             (.invalidResponse, .invalidResponse),
             (.requestTimeout, .requestTimeout),
             (.noInternetConnection, .noInternetConnection),
             (.cancelled, .cancelled),
             (.cacheMiss, .cacheMiss),
             (.uiPresentationError, .uiPresentationError),
             (.missingUIContext, .missingUIContext),
             (.versionComparisonError, .versionComparisonError):
            return true

        case (.invalidConfiguration(let lhsMessage), .invalidConfiguration(let rhsMessage)):
            return lhsMessage == rhsMessage

        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription

        case (.invalidURL(let lhsURL), .invalidURL(let rhsURL)):
            return lhsURL == rhsURL

        case (.serverError(let lhsCode, let lhsMessage), .serverError(let rhsCode, let rhsMessage)):
            return lhsCode == rhsCode && lhsMessage == rhsMessage

        case (.rateLimitExceeded(let lhsRetry), .rateLimitExceeded(let rhsRetry)):
            return lhsRetry == rhsRetry

        case (.apiError(let lhsCode, let lhsMessage), .apiError(let rhsCode, let rhsMessage)):
            return lhsCode == rhsCode && lhsMessage == rhsMessage

        case (.missingData(let lhsData), .missingData(let rhsData)):
            return lhsData == rhsData

        case (.decodingError(let lhsError), .decodingError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription

        case (.cacheError(let lhsError), .cacheError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription

        case (.invalidVersionFormat(let lhsVersion), .invalidVersionFormat(let rhsVersion)):
            return lhsVersion == rhsVersion

        default:
            return false
        }
    }
}

// MARK: - Error Extensions

extension Error {

    /// Convert any error to ReleazioError if possible
    /// - Returns: ReleazioError or generic network error
    func asReleazioError() -> ReleazioError {
        if let releazioError = self as? ReleazioError {
            return releazioError
        }

        if (self as NSError).domain == NSURLErrorDomain {
            return .networkError(self)
        }

        return .networkError(self)
    }
}