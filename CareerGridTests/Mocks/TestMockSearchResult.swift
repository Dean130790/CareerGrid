//
//  TestMockSearchResult.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 08/06/26.
//

import Foundation
@testable import CareerGrid

extension SearchResult {
    static let mock = SearchResult(id: "1", rank: 1, jobTitle: "Senior SRE", companyDetails: CompanyDetails(id: "1", name: "Stripe"))

    static let mock2 = SearchResult(id: "3", rank: 3, jobTitle: "Agile Coach", companyDetails: CompanyDetails(id: "1", name: "Airbnb"))

    static let mockList: [SearchResult] = [
        .mock,
        .mock2
    ]

//    static let completeMockList: [SearchResult] = {
//        do {
//            let dtos: [SearchResultDTO] = try MockLoader.load(filename: "search_results", type: [SearchResultDTO].self)
//            return dtos.map { $0.toDomain() }
//        } catch {
//            fatalError("Failed loading mock jobs: \(error)")
//        }
//    }()
}
