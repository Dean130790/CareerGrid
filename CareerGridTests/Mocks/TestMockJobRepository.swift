//
//  TestMockJobRepository.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 08/06/26.
//

@testable import CareerGrid

public final class TestMockJobRepository: JobRepositoryProtocol {
    
    private var stubbedJob: Result<Job?, Error>
    private var stubbedJobResponse: Result<JobResponse, Error>
    private var stubbedSearchResults: Result<[SearchResult], Error>
    
    public var jobFetch: Bool
    public var searchResultFetch: Bool
    public var jobDetailsFetch: Bool
    
    public init() {
        self.stubbedJob = .success(nil)
        self.stubbedJobResponse = .success(JobResponse(totalCount: 0, jobs: []))
        self.stubbedSearchResults = .success([])
        self.jobFetch = false
        self.searchResultFetch = false
        self.jobDetailsFetch = false
    }
    
    public func fetchJobs(page: Int, limit: Int, policy: CachePolicy) async throws -> JobResponse {
        jobFetch = true
        return try stubbedJobResponse.get()
    }
    
    public func searchJobs(query: String) async throws -> [SearchResult] {
        searchResultFetch = true
        return try stubbedSearchResults.get()
    }
    
    public func fetchJobDetails(jobID: String) async throws -> Job? {
        jobDetailsFetch = true
        return try stubbedJob.get()
    }
    
    public func clearLocalDB() { }
}

extension TestMockJobRepository {
    func stub(jobResponse: Result<JobResponse, Error> = .success(JobResponse(totalCount: 0, jobs: [])), searchResults: Result<[SearchResult], Error> = .success([]), job: Result<Job?, Error> = .success(nil)) {
        stubbedJobResponse = jobResponse
        stubbedSearchResults = searchResults
        stubbedJob = job
    }
}
