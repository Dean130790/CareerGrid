//
//  JobEntity.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation
import SwiftData

@Model
public final class JobEntity {
    @Attribute(.unique)
    public var id: String
    var title: String
    var company: CompanyEntity
    var salaryRange: String
    var jobDetails: String
    var rank: Int
    var updatedAt: Date

    init(id: String, title: String, company: CompanyEntity, salaryRange: String, jobDetails: String, rank: Int, updatedAt: Date = .now) {
        self.id = id
        self.title = title
        self.company = company
        self.salaryRange = salaryRange
        self.jobDetails = jobDetails
        self.rank = rank
        self.updatedAt = updatedAt
    }
}

@Model
public final class CompanyEntity {
    @Attribute(.unique)
    public var id: String
    var name: String
    var address: String

    init(id: String, name: String, address: String) {
        self.id = id
        self.name = name
        self.address = address
    }
}

