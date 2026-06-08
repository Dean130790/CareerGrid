//
//  JobResponseDTO+MockJSON.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

extension JobResponseDTO {
    static let completeMockList: JobResponseDTO = {
        do {
            return try MockLoader.load(filename: "jobs", type: JobResponseDTO.self)
        } catch {
            fatalError("Failed loading mock jobs: \(error)")
        }
    }()
}
