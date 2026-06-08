//
//  JobEntityMapper.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

extension JobEntity {
    func toDomain() -> Job {
        Job(id: id,
            title: title,
            company: Company(id: company.id,
                             name: company.name,
                             address: company.address
                            ),
            salaryRange: salaryRange,
            jobDetails: jobDetails,
            rank: rank
        )
    }
}
