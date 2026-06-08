//
//  SearchResultMapper.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

extension SearchResultDTO {
    func toDomain() -> SearchResult {
        SearchResult(id: id,
                     rank: rank,
                     jobTitle: jobTitle,
                     companyDetails:
                        CompanyDetails(id: company.id,
                                       name: company.name
                                      )
        )
    }
}
