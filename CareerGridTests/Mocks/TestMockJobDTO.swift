//
//  TestMockJobDTO.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 08/06/26.
//

import Foundation
@testable import CareerGrid

extension JobDTO {
    static let mock1 = JobDTO(id: "1",
                              title: "Senior SRE",
                              company: CompanyDTO(id: "1", name: "Stripe", address: "San Francisco, CA, USA"),
                              salaryRange: "$140k - $180k",
                              jobDetails: "Build and maintain the Stripe iOS SDK and consumer-facing payment app used by millions globally. Work closely with backend and design teams to ship reliable, high-performance Swift features in an agile environment.",
                              rank: 1
    )
    
    static let mock2 = JobDTO(id: "3",
                              title: "Agile Coach",
                              company: CompanyDTO(id: "3", name: "Airbnb", address: "San Francisco, CA, USA"),
                              salaryRange: "$180k - $230k",
                              jobDetails: "Define and evolve the iOS platform strategy across Airbnb's host and guest apps with 100M+ users. Partner with product and data teams to drive experimentation, performance improvements, and A/B testing frameworks.",
                              rank: 3
    )
    
    static let mockList: [JobDTO] = [
        .mock1,
        .mock2
    ]
}
