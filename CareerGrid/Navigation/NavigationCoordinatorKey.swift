//
//  NavigationCoordinatorKey.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import SwiftUI

private struct NavigationCoordinatorKey: EnvironmentKey {
    static let defaultValue = NavigationCoordinator()
}

extension EnvironmentValues {
    var navigationCoordinator: NavigationCoordinator {
        get { self[NavigationCoordinatorKey.self] }
        set { self[NavigationCoordinatorKey.self] = newValue }
    }
}
