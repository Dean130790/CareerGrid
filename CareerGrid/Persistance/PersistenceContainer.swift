//
//  Untitled.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import SwiftData

@MainActor
public final class PersistenceContainer {
    let container: ModelContainer

    init(inMemory: Bool = false) {
        do {
            let schema = Schema([JobEntity.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
            container = try ModelContainer(for: schema, configurations: modelConfiguration)
        } catch {
            fatalError("Failed to initialize SwiftData: \(error)")
        }
    }
}
