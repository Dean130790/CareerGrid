//
//  MockHTTPClient.swift
//  NetworkingKit
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

public actor MockHTTPClient: HTTPClient {

    nonisolated(unsafe) var stubbedData: Data
    nonisolated(unsafe) var stubbedResponse: URLResponse
    nonisolated(unsafe) var stubbedError: Error?

    nonisolated(unsafe) private(set) var capturedRequests: [URLRequest]


    public init() {
        self.stubbedData = Data()
        self.stubbedResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        self.capturedRequests = []
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        capturedRequests.append(request)

        if let error = stubbedError {
            throw error
        }
        return (stubbedData, stubbedResponse)
    }
}

// MARK: - Convenience helpers for tests
extension MockHTTPClient {
    nonisolated func stub<T: Encodable>(with model: T, statusCode: Int = 200) throws {
        stubbedData = try JSONEncoder().encode(model)
        stubbedResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}
