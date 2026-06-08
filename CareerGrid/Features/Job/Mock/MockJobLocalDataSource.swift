//
//  MockJobLocalDataSource.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

public final class MockJobLocalDataSource: JobLocalDataSourceProtocol {
    private var storage: [JobEntity] = []

    public init() {}

    public func saveJobs(_ jobs: [JobEntity]) throws {
        for job in jobs {
            if let index = storage.firstIndex(where: { $0.id == job.id }) {
                storage[index] = job
            } else {
                storage.append(job)
            }
        }
    }

    public func fetchJobs(page: Int, limit: Int) throws -> [JobEntity] {
        let offset = (page - 1) * limit
        let paged = Array(storage.sorted { $0.rank < $1.rank }.dropFirst(offset).prefix(limit))
        return paged
    }

    public func lastUpdatedAt(page: Int, limit: Int) throws -> Date? {
        let offset = (page - 1) * limit
        let paged = Array(storage.sorted { $0.rank < $1.rank }.dropFirst(offset).prefix(limit))
        return paged.first?.updatedAt
    }

    public func clear() throws {
        storage.removeAll()
    }
}
