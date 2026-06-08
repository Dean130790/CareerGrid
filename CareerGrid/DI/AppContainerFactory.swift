//
//  AppContainerFactory.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

enum AppContainerFactory {
    static func make(environment: AppEnvironment) -> AppContainer {
        switch environment {
        case .live:
            LiveAppContainer.shared
        case .mock:
            MockAppContainer.shared
        case .preview:
            MockAppContainer.shared
        }
    }
}
