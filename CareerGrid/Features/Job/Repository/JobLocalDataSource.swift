//
//  JobLocalDataSource.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation
import SwiftData

public protocol JobLocalDataSourceProtocol {
    func saveJobs(_ jobs: [JobEntity]) throws
    func fetchJobs(page: Int, limit: Int) throws -> [JobEntity]
    func lastUpdatedAt(page: Int, limit: Int) throws -> Date?
}

public final class JobLocalDataSource: JobLocalDataSourceProtocol {

    private let context: ModelContext

    public init(context: ModelContext) {
        self.context = context
    }

    public func saveJobs(_ jobs: [JobEntity]) throws {
        for job in jobs {
            try upsertJobt(job)
        }
        try context.save()
    }

    public func fetchJobs(page: Int, limit: Int) throws -> [JobEntity] {
        let offset = (page - 1) * limit
        var jobDescriptor = FetchDescriptor<JobEntity>(sortBy: [SortDescriptor(\.rank)])
        jobDescriptor.fetchOffset = offset
        jobDescriptor.fetchLimit = 20
        let entities = try context.fetch(jobDescriptor)
        return entities
    }

    public func lastUpdatedAt(page: Int, limit: Int) throws -> Date? {
        return try fetchJobs(page: page, limit: page).first?.updatedAt
    }

    public func clear() throws {
        try context.delete(model: JobEntity.self)
        try context.save()
    }
}

private extension JobLocalDataSource {
    func upsertJobt(_ job: JobEntity) throws {
        let id = job.id
        let descriptor = FetchDescriptor<JobEntity>(predicate: #Predicate { $0.id == id })
        if let existing = try context.fetch(descriptor).first {
            existing.title = job.title
            existing.company.id = job.company.id
            existing.company.name = job.company.name
            existing.company.address = job.company.address
            existing.salaryRange = job.salaryRange
            existing.jobDetails = job.jobDetails
            existing.updatedAt = .now
        } else {
            context.insert(job)
        }
    }
}
