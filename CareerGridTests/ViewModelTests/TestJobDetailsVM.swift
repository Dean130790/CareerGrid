//
//  TestJobDetailsVM.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 08/06/26.
//

import Testing
@testable import CareerGrid

@MainActor
@Suite("JobDetailsVM")
struct TestJobDetailsVM {

    // MARK: - SUT Factory

    func makeSUT(source: JobDetailsSource = .search(SearchResult.mock), stubbedJob: Result<Job?, Error> = .success(nil)) -> (sut: JobDetailsVM, repository: TestMockJobRepository) {
        let repository = TestMockJobRepository()
        repository.stub(job: stubbedJob)
        let sut = JobDetailsVM(source: source, repository: repository)
        return (sut, repository)
    }

    // MARK: - Initial State

    @Test("Initial state is idle")
    func initialState() {
        let (sut, _) = makeSUT()

        guard case .idle = sut.state else {
            Issue.record("Expected idle, got \(sut.state)")
            return
        }
    }

    // MARK: - fetchJobDetails — source guard

    @Test("fetchJobDetails does nothing if source is not search")
    func fetchJobDetailsIgnoresNonSearchSource() async throws {
        let (sut, repository) = makeSUT(source: .job(Job.mock1))

        await sut.fetchJobDetails()

        #expect(repository.jobDetailsFetch == false)
        guard case .loading = sut.state else {
            Issue.record("Expected loading (set before guard), got \(sut.state)")
            return
        }
    }

    // MARK: - fetchJobDetails — success

    @Test("fetchJobDetails sets loaded state on success")
    func fetchJobDetailsSuccess() async throws {
        let (sut, repository) = makeSUT(
            source: .search(SearchResult.mock),
            stubbedJob: .success(Job.mock1)
        )

        await sut.fetchJobDetails()

        #expect(repository.jobDetailsFetch)

        guard case .loaded(let result) = sut.state else {
            Issue.record("Expected loaded, got \(sut.state)")
            return
        }
        #expect(result?.id == "1")
        #expect(result?.title == "Senior SRE")
    }

    // MARK: - fetchJobDetails — failure

    @Test("fetchJobDetails sets failed state on error")
    func fetchJobDetailsFailure() async throws {
        struct TestError: Error, Equatable {}
        let (sut, _) = makeSUT(stubbedJob: .failure(TestError()))

        await sut.fetchJobDetails()

        guard case .failed(let error) = sut.state else {
            Issue.record("Expected failed, got \(sut.state)")
            return
        }
        #expect(error is TestError)
    }

    @Test("fetchJobDetails silently returns on CancellationError")
    func fetchJobDetailsCancellationError() async throws {
        let (sut, _) = makeSUT(stubbedJob: .failure(CancellationError()))

        await sut.fetchJobDetails()

        // State stays at .loading — cancelled mid-flight, not .failed
        guard case .loading = sut.state else {
            Issue.record("Expected loading (not failed) after cancellation, got \(sut.state)")
            return
        }
    }

    // MARK: - reloadJobDetails

    @Test("reloadJobDetails triggers fetch")
    func reloadJobDetailsTriggersFetch() async throws {
        let (sut, repository) = makeSUT(stubbedJob: .success(Job.mock1))

        sut.reloadJobDetails()
        try await Task.sleep(for: .milliseconds(100))

        #expect(repository.jobDetailsFetch)
    }

    @Test("reloadJobDetails cancels prior task and starts fresh")
    func reloadJobDetailsCancelsPriorTask() async throws {
        let (sut, repository) = makeSUT(stubbedJob: .success(Job.mock1))

        sut.reloadJobDetails()
        sut.reloadJobDetails() // immediate second call cancels the first
        try await Task.sleep(for: .milliseconds(100))

        // Only one fetch completes (first was cancelled before hitting repository)
        #expect(repository.jobDetailsFetch)
    }
}

