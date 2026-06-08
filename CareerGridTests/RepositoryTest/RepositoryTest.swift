//
//  RepositoryTest.swift
//  CareerGridTests
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Testing
@testable import CareerGrid
import Foundation

@MainActor
struct RepositoryTest {

    // MARK: - Network Only

    @Test
    func networkOnlyReturnsRemoteData() async throws {
        let remote = TestMockJobRemoteDataSource()
        remote.stub(jobResponse: .success(JobResponseDTO(totalCount: 2, jobs: JobDTO.mockList)))

        let local = TestMockJobLocalDataSource()

        let repository = JobRepository(remote: remote, local: local)

        let result = try await repository.fetchJobs(page: 1, limit: 20, policy: .networkOnly)
        #expect(result.jobs.count == 2)
        #expect(remote.jobFetch == true)
        #expect(remote.searchResultFetch == false)
        #expect(local.saved == true)
        #expect(local.cached == false)
        #expect(try local.lastUpdatedAt(page: 1, limit: 20) != nil)
    }

    @Test
    func networkOnlyThrowsWhenNetworkFails() async {
        let remote = TestMockJobRemoteDataSource()
        remote.stub(jobResponse: .failure(URLError(.notConnectedToInternet)))

        let local = TestMockJobLocalDataSource()

        let repository = JobRepository(remote: remote, local: local)

        await #expect(throws: URLError.self) {
            try await repository.fetchJobs(page: 1, limit: 20, policy: .networkOnly)
        }
    }

    // MARK: - Cache First

    @Test
    func cacheFirstReturnsCachedData() async throws {
        let remote = TestMockJobRemoteDataSource()

        let local = TestMockJobLocalDataSource()
        try local.saveJobs(JobEntity.mockList)

        let repository = JobRepository(remote: remote, local: local)

        let result = try await repository.fetchJobs(page: 1, limit: 20, policy: .cacheFirst(expiration: 300))
        #expect(result.jobs.count == 2)
        #expect(remote.jobFetch == false)
        #expect(remote.searchResultFetch == false)
        #expect(local.saved == true)// As are are setting data to test.
        #expect(local.cached == true)
        #expect(try local.lastUpdatedAt(page: 1, limit: 20) != nil)
    }

    @Test
    func cacheFirstFetchesRemoteWhenCacheEmpty() async throws {
        let remote = TestMockJobRemoteDataSource()
        remote.stub(jobResponse: .success(JobResponseDTO(totalCount: 2, jobs: JobDTO.mockList)))

        let local = TestMockJobLocalDataSource()

        let repository = JobRepository(remote: remote, local: local)

        let result = try await repository.fetchJobs(page: 1, limit: 20, policy: .cacheFirst(expiration: 300))
        #expect(result.jobs.count == 2)
        #expect(remote.jobFetch == true)
        #expect(remote.searchResultFetch == false)
        #expect(local.saved == true)
        #expect(local.cached == false)
        #expect(try local.lastUpdatedAt(page: 1, limit: 20) != nil)
    }

    @Test
    func cacheFirstReturnsCacheWhenNetworkFails() async throws {
        let remote = TestMockJobRemoteDataSource()
        remote.stub(jobResponse: .failure(URLError(.notConnectedToInternet)))

        let local = TestMockJobLocalDataSource()
        try local.saveJobs(JobEntity.mockList)
        local.lastSyncDateValue = Date(timeIntervalSinceNow: -600)

        let repository = JobRepository(remote: remote, local: local)

        let result = try await repository.fetchJobs(page: 1, limit: 20, policy: .cacheFirst(expiration: 300))
        #expect(result.jobs.count == 2)
        #expect(remote.jobFetch == true)
        #expect(remote.searchResultFetch == false)
        #expect(local.saved == true)
        #expect(local.cached == true)
        #expect(try local.lastUpdatedAt(page: 1, limit: 20) != nil)
    }

    @Test
    func cacheFirstThrowsWhenNetworkFailsAndCacheEmpty() async {
        let remote = TestMockJobRemoteDataSource()
        remote.stub(jobResponse: .failure(URLError(.notConnectedToInternet)))

        let local = TestMockJobLocalDataSource()

        let repository = JobRepository(remote: remote, local: local)

        await #expect(throws: URLError.self) {
            try await repository.fetchJobs(page: 1, limit: 20, policy: .cacheFirst(expiration: 300))
        }
    }

    // MARK: - Stale While Revalidate

    @Test
    func staleWhileRevalidateReturnsCacheImmediately() async throws {
        let remote = TestMockJobRemoteDataSource()

        let local = TestMockJobLocalDataSource()
        try local.saveJobs(JobEntity.mockList)

        let repository = JobRepository(remote: remote, local: local)

        let result = try await repository.fetchJobs(page: 1, limit: 20, policy: .staleWhileRevalidate(expiration: 300))
        #expect(result.jobs.count == 2)
        #expect(remote.jobFetch == false)
        #expect(remote.searchResultFetch == false)
        #expect(local.saved == true)
        #expect(local.cached == true)
        #expect(try local.lastUpdatedAt(page: 1, limit: 20) != nil)
    }

    @Test
    func staleWhileRevalidateTriggersRefreshWhenExpired() async throws {
        let remote = TestMockJobRemoteDataSource()
        remote.stub(jobResponse: .success(JobResponseDTO(totalCount: 2, jobs: JobDTO.mockList)))


        let local = TestMockJobLocalDataSource()
        try local.saveJobs(JobEntity.mockList)
        local.lastSyncDateValue = Date(timeIntervalSinceNow: -600)// 10min back time

        let repository = JobRepository(remote: remote, local: local)

        let result = try await repository.fetchJobs(page: 1, limit: 20, policy: .staleWhileRevalidate(expiration: 300))
        #expect(result.jobs.count == 2)
        #expect(remote.jobFetch == false)
        #expect(remote.searchResultFetch == false)
        #expect(local.saved == true)
        #expect(local.cached == true)
        #expect(try local.lastUpdatedAt(page: 1, limit: 20) != nil)
    }

    @Test
    func staleWhileRevalidateReturnsCacheWhenNetworkFails() async throws {
        let remote = TestMockJobRemoteDataSource()
        remote.stub(jobResponse: .failure(URLError(.notConnectedToInternet)))

        let local = TestMockJobLocalDataSource()
        try local.saveJobs(JobEntity.mockList)

        let repository = JobRepository(remote: remote, local: local)

        let result = try await repository.fetchJobs(page: 1, limit: 20, policy: .staleWhileRevalidate(expiration: 300))
        #expect(result.jobs.count == 2)
        #expect(remote.jobFetch == false)
        #expect(remote.searchResultFetch == false)
        #expect(local.saved == true)
        #expect(local.cached == true)
        #expect(try local.lastUpdatedAt(page: 1, limit: 20) != nil)
    }

    @Test
    func staleWhileRevalidateThrowsWhenNetworkFailsAndCacheEmpty() async {
        let remote = TestMockJobRemoteDataSource()
        remote.stub(jobResponse: .failure(URLError(.notConnectedToInternet)))

        let local = TestMockJobLocalDataSource()

        let repository = JobRepository(remote: remote, local: local)

        await #expect(throws: URLError.self) {
            try await repository.fetchJobs(page: 1, limit: 20, policy: .cacheFirst(expiration: 300))
        }
    }

    // MARK: - Pagination

    @Test
    func paginationReturnsCorrectRemoteItems() async throws {
        let remote = TestMockJobRemoteDataSource()
        let dtos = JobResponseDTO.completeMockList.jobs
        let paged = Array(dtos.dropFirst(40).prefix(20))
        remote.stub(jobResponse: .success(JobResponseDTO(totalCount: 2, jobs: paged)))

        let local = TestMockJobLocalDataSource()

        let repository = JobRepository(remote: remote, local: local)

        let result = try await repository.fetchJobs(page: 3, limit: 20, policy: .networkOnly)
        #expect(result.jobs.count == 20)
        #expect(result.jobs.first?.rank == 41)
        #expect(remote.jobFetch == true)
        #expect(remote.searchResultFetch == false)
        #expect(local.saved == true)
        #expect(local.cached == false)
        #expect(try local.lastUpdatedAt(page: 1, limit: 20) != nil)
    }

    @Test
    func paginationReturnsCorrectLocalItems() async throws {
        let remote = TestMockJobRemoteDataSource()

        let local = TestMockJobLocalDataSource()
        let dtos = JobResponseDTO.completeMockList.jobs
        let paged = Array(dtos.dropFirst(20).prefix(20))
        let jobs = paged.map { $0.toEntity() }
        try local.saveJobs(jobs)

        let repository = JobRepository(remote: remote, local: local)

        let result = try await repository.fetchJobs(page: 2, limit: 20, policy: .cacheFirst(expiration: 300))
        #expect(result.jobs.count == 20)
        #expect(result.jobs.first?.rank == 21)
        #expect(remote.jobFetch == false)
        #expect(remote.searchResultFetch == false)
        #expect(local.saved == true)
        #expect(local.cached == true)
        #expect(try local.lastUpdatedAt(page: 1, limit: 20) != nil)
    }
}
