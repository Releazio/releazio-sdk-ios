//
//  ReleazioTests.swift
//  ReleazioTests
//
//  Created by Releazio Team on 05.10.2025.
//

import XCTest
@testable import Releazio

final class ReleazioTests: XCTestCase {

    // MARK: - Test Configuration

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Reset shared instance for each test
        Releazio.shared.reset()
    }

    override func tearDownWithError() throws {
        Releazio.shared.reset()
        try super.tearDownWithError()
    }

    // MARK: - Configuration Tests

    func testSDKConfiguration() throws {
        // Given
        let configuration = ReleazioConfiguration.development(
            apiKey: "test-api-key",
            applicationId: "test-app-id"
        )

        // When
        Releazio.configure(with: configuration)

        // Then
        let retrievedConfig = Releazio.shared.getConfiguration()
        XCTAssertNotNil(retrievedConfig)
        XCTAssertEqual(retrievedConfig?.apiKey, "test-api-key")
        XCTAssertEqual(retrievedConfig?.applicationId, "test-app-id")
        XCTAssertEqual(retrievedConfig?.environment, .development)
        XCTAssertTrue(retrievedConfig?.debugLoggingEnabled == true)
    }

    func testConfigurationValidation() throws {
        // Test valid configuration
        let validConfig = ReleazioConfiguration.production(
            apiKey: "valid-api-key-123",
            applicationId: "valid-app-id"
        )
        XCTAssertTrue(validConfig.validate())

        // Test invalid configurations
        let invalidAPIKeyConfig = ReleazioConfiguration.production(
            apiKey: "short",
            applicationId: "valid-app-id"
        )
        XCTAssertFalse(invalidAPIKeyConfig.validate())

        let emptyAppIdConfig = ReleazioConfiguration.production(
            apiKey: "valid-api-key-123",
            applicationId: ""
        )
        XCTAssertFalse(emptyAppIdConfig.validate())
    }

    func testEnvironmentURLs() throws {
        XCTAssertEqual(ReleazioEnvironment.development.defaultBaseURL.absoluteString, "https://api-dev.releazio.com/v1")
        XCTAssertEqual(ReleazioEnvironment.staging.defaultBaseURL.absoluteString, "https://api-staging.releazio.com/v1")
        XCTAssertEqual(ReleazioEnvironment.production.defaultBaseURL.absoluteString, "https://api.releazio.com/v1")
    }

    // MARK: - Model Tests

    func testReleaseModel() throws {
        // Given
        let releaseData = """
        {
            "id": "release-123",
            "version": "1.2.3",
            "build_number": "456",
            "title": "Test Release",
            "description": "Test description",
            "release_notes": "Test release notes",
            "release_date": "2025-10-05T12:00:00Z",
            "is_mandatory": false,
            "is_active": true,
            "status": "published",
            "environment": "production",
            "tags": ["feature", "bugfix"],
            "created_at": "2025-10-05T10:00:00Z",
            "updated_at": "2025-10-05T12:00:00Z"
        }
        """.data(using: .utf8)!

        // When
        let release = try JSONDecoder().decode(Release.self, from: releaseData)

        // Then
        XCTAssertEqual(release.id, "release-123")
        XCTAssertEqual(release.version, "1.2.3")
        XCTAssertEqual(release.buildNumber, "456")
        XCTAssertEqual(release.title, "Test Release")
        XCTAssertEqual(release.description, "Test description")
        XCTAssertEqual(release.releaseNotes, "Test release notes")
        XCTAssertFalse(release.isMandatory)
        XCTAssertTrue(release.isActive)
        XCTAssertEqual(release.status, .published)
        XCTAssertEqual(release.environment, "production")
        XCTAssertEqual(release.tags, ["feature", "bugfix"])
        XCTAssertEqual(release.versionWithBuild, "1.2.3 (456)")
    }

    func testAppVersion() throws {
        // Test valid versions
        let version1 = try AppVersion(versionString: "1.2.3")
        XCTAssertEqual(version1.major, 1)
        XCTAssertEqual(version1.minor, 2)
        XCTAssertEqual(version1.patch, 3)
        XCTAssertEqual(version1.semanticVersion, "1.2.3")

        let version2 = try AppVersion(versionString: "2.0.0-beta.1+build.123")
        XCTAssertEqual(version2.major, 2)
        XCTAssertEqual(version2.minor, 0)
        XCTAssertEqual(version2.patch, 0)
        XCTAssertEqual(version2.prerelease, "beta.1")
        XCTAssertEqual(version2.build, "build.123")
        XCTAssertTrue(version2.isPrerelease)

        // Test version comparison
        let versionA = try AppVersion(versionString: "1.2.3")
        let versionB = try AppVersion(versionString: "1.2.4")
        XCTAssertTrue(versionB > versionA)

        let versionC = try AppVersion(versionString: "2.0.0")
        let versionD = try AppVersion(versionString: "1.9.9")
        XCTAssertTrue(versionC > versionD)

        // Test invalid versions
        XCTAssertThrowsError(try AppVersion(versionString: "invalid"))
        XCTAssertThrowsError(try AppVersion(versionString: "1.2"))
    }

    func testChangelogModel() throws {
        // Given
        let changelogData = """
        {
            "id": "changelog-123",
            "release_id": "release-123",
            "title": "Version 1.2.3",
            "content": "New features and bug fixes",
            "entries": [
                {
                    "id": "entry-1",
                    "title": "New Feature",
                    "description": "Added exciting new functionality",
                    "category": "feature",
                    "priority": "high",
                    "is_breaking": false
                },
                {
                    "id": "entry-2",
                    "description": "Fixed critical bug",
                    "category": "bugfix",
                    "priority": "critical",
                    "is_breaking": true
                }
            ],
            "created_at": "2025-10-05T12:00:00Z",
            "updated_at": "2025-10-05T12:00:00Z"
        }
        """.data(using: .utf8)!

        // When
        let changelog = try JSONDecoder().decode(Changelog.self, from: changelogData)

        // Then
        XCTAssertEqual(changelog.id, "changelog-123")
        XCTAssertEqual(changelog.releaseId, "release-123")
        XCTAssertEqual(changelog.title, "Version 1.2.3")
        XCTAssertEqual(changelog.entries.count, 2)

        let featureEntry = changelog.entries(in: .feature).first!
        XCTAssertEqual(featureEntry.title, "New Feature")
        XCTAssertEqual(featureEntry.category, .feature)
        XCTAssertEqual(featureEntry.priority, .high)

        let bugfixEntry = changelog.entries(in: .bugfix).first!
        XCTAssertEqual(bugfixEntry.description, "Fixed critical bug")
        XCTAssertTrue(bugfixEntry.isBreaking)
        XCTAssertEqual(bugfixEntry.priority, .critical)
    }

    func testChangelogCategory() throws {
        XCTAssertEqual(ChangelogCategory.feature.displayName, "Features")
        XCTAssertEqual(ChangelogCategory.feature.iconName, "star.fill")
        XCTAssertEqual(ChangelogCategory.bugfix.displayName, "Bug Fixes")
        XCTAssertEqual(ChangelogCategory.bugfix.iconName, "ladybug.fill")
        XCTAssertEqual(ChangelogCategory.security.displayName, "Security")
        XCTAssertEqual(ChangelogCategory.security.iconName, "shield.fill")
    }

    // MARK: - Error Tests

    func testReleazioError() throws {
        // Test error descriptions
        let configError = ReleazioError.configurationMissing
        XCTAssertNotNil(configError.errorDescription)
        XCTAssertTrue(configError.errorDescription!.contains("not configured"))

        let networkError = ReleazioError.noInternetConnection
        XCTAssertNotNil(networkError.errorDescription)
        XCTAssertTrue(networkError.errorDescription!.contains("No internet"))

        let versionError = ReleazioError.invalidVersionFormat("1.2.3.4")
        XCTAssertNotNil(versionError.errorDescription)
        XCTAssertTrue(versionError.errorDescription!.contains("Invalid version format"))

        // Test error equality
        let error1 = ReleazioError.invalidApiKey
        let error2 = ReleazioError.invalidApiKey
        XCTAssertEqual(error1, error2)

        let error3 = ReleazioError.serverError(statusCode: 500, message: "Server error")
        let error4 = ReleazioError.serverError(statusCode: 500, message: "Server error")
        XCTAssertEqual(error3, error4)

        let error5 = ReleazioError.serverError(statusCode: 404, message: "Not found")
        XCTAssertNotEqual(error3, error5)
    }

    // MARK: - Service Tests

    func testReleaseServiceConfiguration() throws {
        // Given
        let configuration = ReleazioConfiguration.development(
            apiKey: "test-api-key",
            applicationId: "test-app-id"
        )
        let releaseService = ReleaseService()

        // When
        releaseService.configure(with: configuration)

        // Then
        // Note: This test would need to expose internal configuration or use dependency injection
        // For now, we'll just test that the service can be configured without crashing
        XCTAssertNotNil(releaseService)
    }

    func testCacheServiceBasicOperations() throws {
        // Given
        let cacheService = CacheService()
        let testKey = "test-key"
        let testValue = "test-value"

        // When/Then - Test set and get
        let expectation = XCTestExpectation(description: "Cache set and get")
        Task {
            do {
                try await cacheService.set(testValue, key: testKey, timeout: 3600)
                let retrievedValue: String? = try await cacheService.get(String.self, key: testKey)
                XCTAssertEqual(retrievedValue, testValue)

                // Test remove
                try await cacheService.remove(key: testKey)
                let removedValue: String? = try await cacheService.get(String.self, key: testKey)
                XCTAssertNil(removedValue)

                expectation.fulfill()
            } catch {
                XCTFail("Cache operations failed: \(error)")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testAnalyticsServiceEventTracking() throws {
        // Given
        let analyticsService = AnalyticsService()
        let configuration = ReleazioConfiguration.development(
            apiKey: "test-api-key",
            applicationId: "test-app-id",
            analyticsEnabled: true
        )

        // When
        analyticsService.configure(with: configuration)

        // Then - Test that events can be tracked without crashing
        analyticsService.trackEvent(.sdkInitialized)
        analyticsService.trackEvent(.releasesFetched(count: 5))
        analyticsService.trackEvent(.custom(name: "test_event", properties: ["test": "value"]))

        XCTAssertEqual(analyticsService.getEventCount(), 3)

        // Test flush
        analyticsService.flushEvents()
        // Note: In a real test with mocked network manager, we'd verify events are sent
    }

    // MARK: - Network Tests (Mock)

    func testAPIEndpoints() throws {
        // Test endpoint URL generation
        let releasesURL = APIEndpoints.getReleases(
            applicationId: "test-app",
            environment: "production",
            page: 1,
            perPage: 20
        )
        XCTAssertTrue(releasesURL.absoluteString.contains("/applications/test-app/releases"))
        XCTAssertTrue(releasesURL.absoluteString.contains("environment=production"))
        XCTAssertTrue(releasesURL.absoluteString.contains("page=1"))
        XCTAssertTrue(releasesURL.absoluteString.contains("per_page=20"))

        let latestReleaseURL = APIEndpoints.getLatestRelease(
            applicationId: "test-app",
            environment: "staging"
        )
        XCTAssertTrue(latestReleaseURL.absoluteString.contains("/applications/test-app/releases/latest"))
        XCTAssertTrue(latestReleaseURL.absoluteString.contains("environment=staging"))

        let changelogURL = APIEndpoints.getChangelog(
            applicationId: "test-app",
            releaseId: "release-123",
            locale: "en"
        )
        XCTAssertTrue(changelogURL.absoluteString.contains("/applications/test-app/releases/release-123/changelog"))
        XCTAssertTrue(changelogURL.absoluteString.contains("locale=en"))
    }

    func testAPIRequestCreation() throws {
        // Test GET request
        let getRequest = APIRequest.get(
            url: URL(string: "https://api.example.com/test")!,
            headers: ["Custom-Header": "value"],
            timeout: 60
        )
        XCTAssertEqual(getRequest.method, .GET)
        XCTAssertEqual(getRequest.headers["Custom-Header"], "value")
        XCTAssertEqual(getRequest.timeout, 60)

        // Test POST request
        let testData = ["key": "value"]
        let postRequest = try APIRequest.post(
            url: URL(string: "https://api.example.com/test")!,
            body: testData
        )
        XCTAssertEqual(postRequest.method, .POST)
        XCTAssertEqual(postRequest.headers["Content-Type"], "application/json")
        XCTAssertNotNil(postRequest.body)
    }

    // MARK: - Performance Tests

    func testAppVersionComparisonPerformance() throws {
        // Given
        let version1 = try AppVersion(versionString: "1.2.3")
        let version2 = try AppVersion(versionString: "2.0.0")
        let version3 = try AppVersion(versionString: "1.2.4")

        // When/Then
        measure {
            for _ in 0..<1000 {
                let _ = version2 > version1
                let _ = version3 > version1
                let _ = version1 < version2
            }
        }
    }

    func testCacheServicePerformance() throws {
        // Given
        let cacheService = CacheService()
        let testValue = "test-value"

        // When/Then
        measure {
            let expectation = XCTestExpectation(description: "Cache performance")
            Task {
                for i in 0..<100 {
                    let key = "test-key-\(i)"
                    try? await cacheService.set(testValue, key: key, timeout: 3600)
                    let _: String? = try? await cacheService.get(String.self, key: key)
                }
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10.0)
        }
    }

    // MARK: - Integration Tests (Mock)

    func testSDKIntegrationFlow() throws {
        // Given
        let configuration = ReleazioConfiguration.development(
            apiKey: "test-api-key",
            applicationId: "test-app-id"
        )

        // When
        Releazio.configure(with: configuration)

        // Then
        XCTAssertNotNil(Releazio.shared.getConfiguration())

        // Test that SDK is ready for operations
        // Note: These would fail in real scenario without mocked network responses
        // but they should not crash due to configuration issues
        XCTAssertNotNil(Releazio.shared)
        XCTAssertNoThrow(Releazio.shared.reset())
    }
}

// MARK: - Mock Classes for Testing

class MockNetworkManager: NetworkManagerProtocol {
    var shouldSucceed = true
    var mockReleases: [Release] = []
    var mockRelease: Release?
    var mockChangelog: Changelog?

    func getReleases(applicationId: String, environment: String, page: Int?, perPage: Int?) async throws -> [Release] {
        if shouldSucceed {
            return mockReleases
        } else {
            throw ReleazioError.networkError(URLError(.notConnectedToInternet))
        }
    }

    func getLatestRelease(applicationId: String, environment: String) async throws -> Release? {
        if shouldSucceed {
            return mockRelease
        } else {
            throw ReleazioError.networkError(URLError(.notConnectedToInternet))
        }
    }

    func getRelease(applicationId: String, releaseId: String, environment: String) async throws -> Release {
        if shouldSucceed, let release = mockRelease {
            return release
        } else {
            throw ReleazioError.networkError(URLError(.notConnectedToInternet))
        }
    }

    func checkForUpdates(applicationId: String, currentVersion: String, environment: String) async throws -> UpdateCheckResponse {
        if shouldSucceed, let release = mockRelease {
            return UpdateCheckResponse(
                hasUpdate: true,
                latestRelease: release,
                currentVersion: currentVersion,
                updateType: .minor,
                isMandatory: false
            )
        } else {
            throw ReleazioError.networkError(URLError(.notConnectedToInternet))
        }
    }

    func getChangelog(applicationId: String, releaseId: String, locale: String?) async throws -> Changelog {
        if shouldSucceed, let changelog = mockChangelog {
            return changelog
        } else {
            throw ReleazioError.networkError(URLError(.notConnectedToInternet))
        }
    }

    func getChangelogs(applicationId: String, locale: String?, page: Int?, perPage: Int?) async throws -> [Changelog] {
        if shouldSucceed, let changelog = mockChangelog {
            return [changelog]
        } else {
            throw ReleazioError.networkError(URLError(.notConnectedToInternet))
        }
    }

    func trackEvent(applicationId: String, event: AnalyticsEvent) async throws {
        // Mock implementation - does nothing
    }

    func validateAPIKey() async throws -> Bool {
        return shouldSucceed
    }
}