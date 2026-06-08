//
//  HTTPClient.swift
//  NetworkingKit
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

public protocol HTTPClient: Actor {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
