//
//  TestMockSearchResultDTO.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 08/06/26.
//

import Foundation
@testable import CareerGrid

extension SearchResultDTO {
    static let mock1 = SearchResultDTO(id: "1",
                                       rank: 1,
                                       jobTitle: "Senior SRE",
                                       company:
                                        _CompanyDTO(id: "1",
                                                    name: "Stripe"
                                                   )
    )
    
    static let mock2 = SearchResultDTO(id: "3",
                                       rank: 3,
                                       jobTitle: "Agile Coach",
                                       company:
                                        _CompanyDTO(id: "3",
                                                    name: "Airbnb"
                                                   )
    )
    
    static let mockList: [SearchResultDTO] = [
        .mock1,
        .mock2
    ]
}
