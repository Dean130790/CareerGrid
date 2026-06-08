//
//  AppEnvironment.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

enum AppEnvironment {
    case live
    case mock
    case preview

    static var current: Self {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-mock") || arguments.contains("-preview") {
            return .mock
        }
        return .live
    }
}
