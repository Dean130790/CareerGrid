//
//  Job.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

public struct JobResponse: Hashable {
    let totalCount: Int
    let jobs: [Job]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case jobs
    }
}

public struct Job: Identifiable, Hashable {
    public let id: String
    let title: String
    let company: Company
    let salaryRange, jobDetails: String
    let rank: Int

    enum CodingKeys: String, CodingKey {
        case id
        case jobTitle = "job_title"
        case companyDetails = "company_details"
        case salaryRange = "salary_range"
        case jobDetails = "job_details"
        case rank
    }
}

public struct Company: Identifiable, Hashable {
    public let id: String
    let name, address: String
    
    enum CodingKeys: String, CodingKey {
        case id = "company_id"
        case name = "company_name"
        case address = "company_address"
    }
}

typealias Jobs = [Job]
