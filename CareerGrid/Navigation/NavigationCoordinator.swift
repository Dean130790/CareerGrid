//
//  NavigationCoordinator.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class NavigationCoordinator {

    var sheet: AppSheet?
    // var fullscreenCover: FullscreenRoute?

    var path: [AppRoute] = []

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return}
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    func replace(with route: AppRoute) {
        path = [route]
    }
}

enum AppSheet: Identifiable {
    case settings
    var id: String {
        switch self {
        case .settings:
            return "settings"
        }
    }
}

enum RootFlow {
    case auth
    case main
}
