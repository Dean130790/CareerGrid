//
//  TestEndpoint.swift
//  NetworkingKit
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation
@testable import NetworkingKit

enum TestEndpoint: Endpoint, Sendable {
    case test1
    case test2

    var path: String {
        switch self {
        case .test1:
            return "tests/test1"
        case .test2:
            return "tests/test2"
        }
    }

    var method: NetworkingKit.HTTPMethod {
        .get
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .test1:
            return [
                .init(name: "page", value: "\(1)"),
                .init(name: "per_page", value: "20")
            ]
        case .test2:
            return [
                .init(name: "query", value: "iOS")
            ]
        }
    }

    var body: (any Encodable)? { return nil }

    var headers: [String : String] { [:] }
}
