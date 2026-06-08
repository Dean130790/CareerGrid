//
//  NetworkManager.swift
//  NetworkingKit
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

public actor NetworkManager {

    private let client: HTTPClient
    private let baseURL: URL
    private let decoder: JSONDecoder
    private let retryPolicy: RetryPolicy

    public init(
        client: HTTPClient,
        baseURL: URL,
        decoder: JSONDecoder = {
            let d = JSONDecoder()
            d.keyDecodingStrategy = .convertFromSnakeCase
            d.dateDecodingStrategy = .iso8601
            return d
        }(),
        retryPolicy: RetryPolicy = RetryPolicy()
    ) {
        self.client = client
        self.baseURL = baseURL
        self.decoder = decoder
        self.retryPolicy = retryPolicy
    }

    public func request<T: Decodable>(endpoint: Endpoint, responseType: T.Type) async throws -> T {
        var currentAttempt = 0
        var delay = retryPolicy.initialDelay

        while true {
            do {
                let request = try buildRequest(for: endpoint)
                do {
                    let (data, response) = try await client.data(for: request)
                    try validate(response: response, data: data)
                    return try decoder.decode(T.self, from: data)
                } catch let error as DecodingError {
                    throw NetworkError.decodingError(error.localizedDescription)
                } catch let error as URLError where error.code == .cancelled {
                    throw CancellationError()
                } catch let error as NetworkError {
                    throw error
                } catch {
                    throw NetworkError.networkError(error.localizedDescription)
                }
            } catch {
                currentAttempt += 1
                guard currentAttempt <= retryPolicy.maxRetries, shouldRetry(error) else {
                    throw error
                }
                try await Task.sleep(for: delay)
                delay *= 2
            }
        }
    }
}

// MARK: - Private helpers
private extension NetworkManager {
    func buildRequest(for endpoint: Endpoint) throws -> URLRequest {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: true
        )
        components?.queryItems = endpoint.queryItems

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        return request
    }
    
    func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch http.statusCode {
        case 200...299: break
        case 401:       throw NetworkError.unauthorized
        case 404:       throw NetworkError.notFound
        case 500...599: throw NetworkError.serverError(http.statusCode)
        default:        throw NetworkError.httpError(statusCode: http.statusCode, data: data)
        }
    }

    private func shouldRetry(_ error: Error) -> Bool {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .serverError(_), .httpError(_, _):
                return true
            default:
                return false
            }
        }
        return false
    }
}
