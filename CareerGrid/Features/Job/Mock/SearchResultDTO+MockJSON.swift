//
//  SearchResultDTO+MockJSON.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

extension SearchResultDTO {
    static let completeMockList: [SearchResultDTO] = {
        do {
            return try MockLoader.load(filename: "search_results", type: [SearchResultDTO].self)
        } catch {
            fatalError("Failed loading mock search results: \(error)")
        }
    }()
}
