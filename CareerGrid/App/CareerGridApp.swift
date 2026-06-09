//
//  CareerGridApp.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import SwiftUI
import SwiftData

@main
struct CareerGridApp: App {
    
    init() {
        BGSyncManager.shared.register()
        BGSyncManager.shared.scheduleRefresh()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
