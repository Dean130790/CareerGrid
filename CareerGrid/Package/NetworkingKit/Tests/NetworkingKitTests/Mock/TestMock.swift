//
//  Job+Mock.swift
//  NetworkingKit
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

struct TestMock: Identifiable, Hashable, Codable {
    let id, title: String
    let details: TestMockDetails

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case details
    }
}

struct TestMockDetails: Identifiable, Hashable, Codable {
    let id: String
    let name, address: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
    }
}

extension TestMock {
    static let test1 = TestMock(id: "1",
                                title: "Test tilte 1",
                                details: TestMockDetails(id: "1",
                                                         name: "Test name 1",
                                                         address: "Test address 1"
                                                        )
    )

    static let test2 = TestMock(id: "1",
                                title: "Test tilte 2",
                                details: TestMockDetails(id: "1",
                                                         name: "Test name 2",
                                                         address: "Test address 2"
                                                        )
    )

    static let list: [TestMock] = [
        .test1,
        .test2
    ]
}
