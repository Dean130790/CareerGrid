//
//  searchResult.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

public struct SearchResult: Identifiable, Hashable {
    public let id: String
    let rank: Int
    let jobTitle: String
    let companyDetails: CompanyDetails

    enum CodingKeys: String, CodingKey {
        case id, rank
        case jobTitle = "job_title"
        case companyDetails = "company_details"
    }
}

struct CompanyDetails: Identifiable, Hashable {
    public let id: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case id = "company_id"
        case name = "company_name"
    }
}

typealias SearchResults = [SearchResult]
