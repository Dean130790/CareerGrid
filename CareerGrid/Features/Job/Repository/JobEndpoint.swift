//
//  JobEndpoint.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation
import NetworkingKit

enum JobEndpoint: Endpoint, Sendable {
    case jobs(page: Int)
    case search(query: String)
    case jobDetails(id: String)

    var path: String {
        switch self {
        case .jobs:
            return "/jobs"
        case .search:
            return "/search"
        case .jobDetails:
            return "/job"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .jobs(let page):
            return [
                .init(name: "page", value: "\(page)"),
                .init(name: "per_page", value: "20")
            ]
        case .search(let query):
            return [
                .init(name: "query", value: query)
            ]
        case .jobDetails(let id):
            return [
                .init(name: "ids", value: "\(id)")
            ]
        }
    }

    var body: (any Encodable)? { nil }

    var headers: [String : String] { [:] }
}
