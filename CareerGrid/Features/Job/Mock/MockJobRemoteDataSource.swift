//
//  MockJobRemoteDataSource.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

public final class MockJobRemoteDataSource: JobRemoteDataSourceProtocol, Sendable {

    public init() {}

    public func fetchJobs(page: Int, limit: Int) async throws -> JobResponseDTO {
        let offset = (page - 1) * limit
        let completeMock = JobResponseDTO.completeMockList.jobs
        let paged = Array(completeMock.dropFirst(offset).prefix(limit))
        return JobResponseDTO(totalCount: completeMock.count, jobs: paged)
    }

    public func searchJobs(query: String) async throws -> [SearchResultDTO] {
        let completeMock = SearchResultDTO.completeMockList
        let results = completeMock.filter {
            query.isEmpty || $0.jobTitle.localizedCaseInsensitiveContains(query) || $0.company.name.localizedCaseInsensitiveContains(query)
        }
        return results
    }

    public func fetchJobDetails(jobID: String) async throws -> [JobDTO] {
        let completeMock = JobResponseDTO.completeMockList.jobs
        let result = completeMock.filter {
            $0.id == jobID
        }
        return result
    }
}
