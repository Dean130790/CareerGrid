//
//  TestMockJobLocalDataSource.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 08/06/26.
//

import Foundation
@testable import CareerGrid

public final class TestMockJobLocalDataSource: JobLocalDataSourceProtocol {

    var stubbedJobs: [JobEntity]
    var lastSyncDateValue: Date?
    var saved, cached: Bool

    public init() {
        self.stubbedJobs = []
        self.saved = false
        self.cached = false
    }

    public func saveJobs(_ jobs: [JobEntity]) throws {
        self.stubbedJobs = jobs
        lastSyncDateValue = .now
        saved = true
    }
    
    public func fetchJobs(page: Int, limit: Int) throws -> [JobEntity] {
        cached = true
        return stubbedJobs
    }

    public func lastUpdatedAt(page: Int, limit: Int) throws -> Date? {
        return lastSyncDateValue
    }

    public func clear() throws { }
}

extension TestMockJobLocalDataSource {
    func stub(jobs: [JobEntity] = []) {
        stubbedJobs = jobs
    }
}
