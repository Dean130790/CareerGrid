//
//  TestMockJobRemoteDataSource.swift.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 08/06/26.
//

import Foundation
@testable import CareerGrid

public final class TestMockJobRemoteDataSource: JobRemoteDataSourceProtocol, @unchecked Sendable {

    var stubbedJobResponse: Result<JobResponseDTO, Error>
    var stubbedSearchResults: Result<[SearchResultDTO], Error>

    public var jobFetch: Bool
    public var searchResultFetch: Bool

    public init() {
        self.stubbedJobResponse = .success(JobResponseDTO(totalCount: 0, jobs: []))
        self.stubbedSearchResults = .success([])
        self.jobFetch = false
        self.searchResultFetch = false
    }

    public func fetchJobs(page: Int, limit: Int) async throws -> JobResponseDTO {
        jobFetch = true
        return try stubbedJobResponse.get()
    }
    
    public func searchJobs(query: String) async throws -> [SearchResultDTO] {
        searchResultFetch = true
        return try stubbedSearchResults.get()
    }

    public func fetchJobDetails(jobID: String) async throws -> [JobDTO] {
        return try stubbedJobResponse.get().jobs
    }
}

extension TestMockJobRemoteDataSource {
    func stub(jobResponse: Result<JobResponseDTO, Error> = .success(JobResponseDTO(totalCount: 0, jobs: [])), searchResults: Result<[SearchResultDTO], Error> = .success([])) {
        stubbedJobResponse = jobResponse
        stubbedSearchResults = searchResults
    }
}
