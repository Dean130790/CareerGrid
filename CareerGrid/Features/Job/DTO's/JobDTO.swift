//
//  JobDTO.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

public struct JobResponseDTO: Decodable, Sendable {
    let totalCount: Int
    let jobs: [JobDTO]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case jobs
    }
}

public struct JobDTO: Decodable, Sendable {
    let id, title: String
    let company: CompanyDTO
    let salaryRange, jobDetails: String
    let rank: Int

    enum CodingKeys: String, CodingKey {
        case id
        case title = "job_title"
        case company = "company_details"
        case salaryRange = "salary_range"
        case jobDetails = "job_details"
        case rank
    }
}

public struct CompanyDTO: Decodable, Sendable {
    let id: String
    let name, address: String

    enum CodingKeys: String, CodingKey {
        case id = "company_id"
        case name = "company_name"
        case address = "company_address"
    }
}

typealias JobDTOs = [JobDTO]
