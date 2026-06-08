//
//  SearchResultDTO.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

public struct SearchResultDTO: Decodable, Sendable {
    let id: String
    let rank: Int
    let jobTitle: String
    let company: _CompanyDTO

    enum CodingKeys: String, CodingKey {
        case id, rank
        case jobTitle = "job_title"
        case company = "company_details"
    }
}

public struct _CompanyDTO: Decodable, Sendable {
    let id: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "company_id"
        case name = "company_name"
    }
}

typealias SearchResultDTOs = [SearchResultDTO]
