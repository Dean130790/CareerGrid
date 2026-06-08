//
//  RetryPolicy.swift
//  NetworkingKit
//
//  Created by Yatharth Wadekar on 07/06/26.
//

public struct RetryPolicy: Sendable {
    public let maxRetries: Int
    public let initialDelay: Duration

    public init(maxRetries: Int = 3, initialDelay: Duration = .seconds(1)) {
        self.maxRetries = maxRetries
        self.initialDelay = initialDelay
    }
}
