//
//  Retryable.swift
//  NetworkingKit
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

protocol Retryable {
    func shouldRetry(for error: Error) -> Bool
}
