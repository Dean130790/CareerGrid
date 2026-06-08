//
//  Untitled.swift
//  NetworkingKit
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

public enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data)
    case decodingError(String)
    case networkError(String)
    case unauthorized
    case notFound
    case serverError(Int)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:           return "The URL is malformed."
        case .invalidResponse:      return "The server returned an invalid response."
        case .httpError(let code, _): return "HTTP error: \(code)"
        case .decodingError(let msg): return "Failed to decode response: \(msg)"
        case .networkError(let msg):  return "Network error: \(msg)"
        case .unauthorized:          return "Unauthorized. Please log in again."
        case .notFound:              return "Resource not found."
        case .serverError(let code): return "Server error: \(code)"
        }
    }
}

