//
//  HTTPClientTests.swift
//  NetworkingKit
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Testing
import Foundation
@testable import NetworkingKit

@Suite("NetworkManager — Success/Failure Cases")
struct HTTPClientTests {

    // MARK: - Fixtures

    private let baseURL = URL(string: "https://api.example.com")!

    private func makeSUT(
        maxRetries: Int = 0,
        retryDelay: Duration = .milliseconds(1)
    ) -> (sut: NetworkManager, client: MockHTTPClient) {
        let client = MockHTTPClient()
        let sut = NetworkManager(
            client: client,
            baseURL: baseURL,
            retryPolicy: RetryPolicy(maxRetries: maxRetries, initialDelay: retryDelay)
        )
        return (sut, client)
    }

    private func httpResponse(status: Int, url: URL? = nil) -> HTTPURLResponse {
        HTTPURLResponse(
            url: url ?? baseURL,
            statusCode: status,
            httpVersion: nil,
            headerFields: nil
        )!
    }


    // MARK: - NetworkManager — Success Cases

    // MARK: - Decoding

    @Test("200 response returns correctly decoded model")
    func decodesModelOn200() async throws {
        let (sut, client) = makeSUT()
        let expected = TestMock.list
        try client.stub(with: expected)

        let result = try await sut.request(endpoint: TestEndpoint.test1, responseType: [TestMock].self)

        #expect(result == expected)
    }

    // MARK: - Request Construction

    @Test("GET request sends no HTTP body")
    func getRequestHasNoBody() async throws {
        let (sut, client) = makeSUT()
        try client.stub(with: TestMock.test1, statusCode: 200)

        _ = try await sut.request(endpoint: TestEndpoint.test1, responseType: TestMock.self)

        let captured = try #require(client.capturedRequests.first)
        #expect(captured.httpBody == nil)
    }



    // MARK: - NetworkManager — Error Cases

    // MARK: - HTTP Status Errors

    @Test("401 response throws .unauthorized")
    func unauthorized() async throws {
        let (sut, client) = makeSUT()
        try client.stub(with: TestMock.test1, statusCode: 401)

        await #expect(throws: NetworkError.unauthorized) {
            try await sut.request(endpoint: TestEndpoint.test1, responseType: TestMock.self)
        }
    }

    @Test("404 response throws .notFound")
    func notFound() async throws {
        let (sut, client) = makeSUT()
        try client.stub(with: TestMock.test1, statusCode: 404)

        await #expect(throws: NetworkError.notFound) {
            try await sut.request(endpoint: TestEndpoint.test1, responseType: TestMock.self)
        }
    }

    @Test("5xx responses throw .serverError", arguments: [500, 502, 503, 504])
    func serverErrors(statusCode: Int) async throws {
        let (sut, client) = makeSUT()
        try client.stub(with: TestMock.test1, statusCode: statusCode)

        await #expect(throws: NetworkError.serverError(statusCode)) {
            try await sut.request(endpoint: TestEndpoint.test1, responseType: TestMock.self)
        }
    }

    // MARK: - Response Validation

    @Test("Non-HTTP URLResponse throws .invalidResponse")
    func invalidResponseType() async throws {
        let (sut, client) = makeSUT()
        client.stubbedData = Data()
        // Plain URLResponse — not an HTTPURLResponse
        client.stubbedResponse = URLResponse(
            url: baseURL,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )

        await #expect(throws: NetworkError.invalidResponse) {
            try await sut.request(endpoint: TestEndpoint.test1, responseType: TestMock.self)
        }
    }

    // MARK: - Decoding Errors

    @Test("Wrong JSON shape on 200 throws .decodingError")
    func decodingErrorWrongShape() async throws {
        let (sut, client) = makeSUT()
        client.stubbedData = Data(#"{"wrong_key": 999}"#.utf8)
        client.stubbedResponse = httpResponse(status: 200)

        let error = await #expect(throws: NetworkError.self) {
            try await sut.request(endpoint: TestEndpoint.test1, responseType: TestMock.self)
        }
        guard case .decodingError = error else {
            Issue.record("Expected .decodingError, got \(String(describing: error))")
            return
        }
    }

    // MARK: - Network-Level Errors (URLError)

    @Test("URLError.notConnectedToInternet throws .networkError")
    func networkErrorOffline() async throws {
        let (sut, client) = makeSUT()
        client.stubbedError = URLError(.notConnectedToInternet)

        let error = await #expect(throws: NetworkError.self) {
            try await sut.request(endpoint: TestEndpoint.test1, responseType: TestMock.self)
        }
        guard case .networkError = error else {
            Issue.record("Expected .networkError, got \(String(describing: error))")
            return
        }
    }

    @Test("URLError.timedOut throws .networkError")
    func networkErrorTimeout() async throws {
        let (sut, client) = makeSUT()
        client.stubbedError = URLError(.timedOut)

        let error = await #expect(throws: NetworkError.self) {
            try await sut.request(endpoint: TestEndpoint.test1, responseType: TestMock.self)
        }
        guard case .networkError = error else {
            Issue.record("Expected .networkError, got \(String(describing: error))")
            return
        }
    }

    // MARK: - Cancellation

    @Test("URLError.cancelled surfaces as CancellationError (not wrapped)")
    func cancellationPropagated() async throws {
        let (sut, client) = makeSUT()
        client.stubbedError = URLError(.cancelled)

        await #expect(throws: CancellationError.self) {
            try await sut.request(endpoint: TestEndpoint.test1, responseType: TestMock.self)
        }
    }

    // MARK: - Retry Policy

    @Test("Server error retries exactly maxRetries times then throws")
    func retryExhaustion() async throws {
        let (sut, client) = makeSUT(maxRetries: 2, retryDelay: .milliseconds(1))
        try client.stub(with: TestMock.test1, statusCode: 500)

        await #expect(throws: NetworkError.serverError(500)) {
            try await sut.request(endpoint: TestEndpoint.test1, responseType: TestMock.self)
        }

        // 1 initial attempt + 2 retries = 3 total
        let requestCount = client.capturedRequests.count
        #expect(requestCount == 3, "Expected 3 total attempts, got \(requestCount)")
    }

    @Test("Decoding error is NOT retried")
    func noRetryOnDecodeFailure() async throws {
        let (sut, client) = makeSUT(maxRetries: 2, retryDelay: .milliseconds(1))
        client.stubbedData = Data("bad".utf8)
        client.stubbedResponse = httpResponse(status: 200)

        _ = try? await sut.request(endpoint: TestEndpoint.test1, responseType: TestMock.self)

        let requestCount = client.capturedRequests.count
        #expect(requestCount == 1, "Decoding errors must not trigger retry, got \(requestCount) attempts")
    }

    @Test("401 Unauthorized is NOT retried")
    func noRetryOnUnauthorized() async throws {
        let (sut, client) = makeSUT(maxRetries: 2, retryDelay: .milliseconds(1))
        try client.stub(with: TestMock.test1, statusCode: 401)

        _ = try? await sut.request(endpoint: TestEndpoint.test1, responseType: TestMock.self)

        let requestCount = client.capturedRequests.count
        #expect(requestCount == 1, "401 must not trigger retry, got \(requestCount) attempts")
    }
}
