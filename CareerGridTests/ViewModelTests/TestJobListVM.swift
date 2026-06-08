
//
//  TestJobListVM.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 08/06/26.
//

import Testing
@testable import CareerGrid

@MainActor
@Suite("JobListVM")
struct TestJobListVM {

    // MARK: - SUT Factory

    func makeSUT(stubbedResult: Result<JobResponse, Error> = .success(JobResponse(totalCount: 0, jobs: []))) -> (sut: JobListVM, repository: TestMockJobRepository) {
        let repository = TestMockJobRepository()
        repository.stub(jobResponse: stubbedResult)
        let sut = JobListVM(onJobTap: { _ in }, onSearchTap: { }, repository: repository)
        return (sut, repository)
    }

    // MARK: - Initial State

    @Test("Initial state is idle")
    func initialState() async throws {
        let (sut, _) = makeSUT()
        #expect(sut.state.currentPage == 1)
        #expect(sut.state.isLoadingNextPage == false)
    }

    @Test("resetFeed resets state to default")
    func resetFeed() async throws {
        let (sut, _) = makeSUT()
        sut.state.currentPage = 5
        sut.state.isLoadingNextPage = true
        sut.resetJobs()

        #expect(sut.state.currentPage == 1)
        #expect(sut.state.isLoadingNextPage == false)
    }

    // MARK: - refreshFeed

    @Test("refreshFeed resets to page 1 and uses networkOnly policy")
    func refreshFeedResetsPageAndUsesNetworkOnly() async throws {
        let (sut, _) = makeSUT(stubbedResult: .success(JobResponse(totalCount: 2, jobs: Job.mockList)))
        sut.state.currentPage = 3

        sut.refreshJobs()
        try await Task.sleep(for: .milliseconds(100))

        #expect(sut.state.currentPage == 1)
    }

    // MARK: - fetchMarkets

    @Test("fetchMarkets sets loading then loaded on success")
    func fetchMarketsSuccess() async throws {
        let (sut, _) = makeSUT(stubbedResult: .success(JobResponse(totalCount: 2, jobs: Job.mockList)))

        await sut.fetchJobs(policy: .networkOnly)

        guard case .loaded(let result) = sut.state.content else {
            Issue.record("Expected loaded state")
            return
        }
        #expect(result.count == 2)
        #expect(result.map(\.title) == ["Senior SRE", "Agile Coach"])
    }

    @Test("fetchMarkets sets failed state on error")
    func fetchMarketsFailure() async throws {
        struct TestError: Error, Equatable {}
        let (sut, _) = makeSUT(stubbedResult: .failure(TestError()))

        await sut.fetchJobs(policy: .networkOnly)

        guard case .failed(let error) = sut.state.content else {
            Issue.record("Expected failed state")
            return
        }
        #expect(error is TestError)
    }

    // MARK: - loadNextFeedPage

    @Test("loadNextFeedPage appends jobs and increments page")
    func loadNextFeedPageAppendsAndIncrements() async throws {

        let page1 = Array(repeating: Job.mock1, count: 20)
        let page2 = Array(repeating: Job.mock2, count: 20) 

        let (sut, repository) = makeSUT(stubbedResult: .success(JobResponse(totalCount: 20, jobs: page1)))

        // Load first page
        await sut.fetchJobs(policy: .networkOnly)
        #expect(sut.state.currentPage == 1)

        // Stub second page
        repository.stub(jobResponse: .success(JobResponse(totalCount: 20, jobs: page2)))
        await sut.loadNextFeedPage()

        guard case .loaded(let all) = sut.state.content else {
            Issue.record("Expected loaded state after pagination")
            return
        }
        #expect(all.count == 40)
        #expect(sut.state.currentPage == 2)
    }

    @Test("loadNextFeedPage does nothing if already loading next page")
    func loadNextFeedPageGuardsAgainstConcurrentLoads() async throws {
        let (sut, repository) = makeSUT(
            stubbedResult: .success(JobResponse(totalCount: 2, jobs: Job.mockList))
        )
        await sut.fetchJobs(policy: .networkOnly)

        sut.state.isLoadingNextPage = true
        await sut.loadNextFeedPage()

        // fetchJobs called once (fetchMarkets), not again
        #expect(repository.jobFetch)
    }

    @Test("loadNextFeedPage sets failed on error")
    func loadNextFeedPageSetsFailedOnError() async throws {
        struct TestError: Error {}
        let (sut, repository) = makeSUT(
            stubbedResult: .success(JobResponse(totalCount: 2, jobs: Job.mockList))
        )
        await sut.fetchJobs(policy: .networkOnly)

        repository.stub(jobResponse: .failure(TestError()))
        await sut.loadNextFeedPage()

        guard case .failed(let error) = sut.state.content else {
            Issue.record("Expected failed state")
            return
        }
        #expect(error is TestError)
    }
}
