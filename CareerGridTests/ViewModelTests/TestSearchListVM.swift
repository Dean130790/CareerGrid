//
//  TestSearchListVM.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 08/06/26.
//

import Testing
@testable import CareerGrid
import Foundation

@MainActor
@Suite("SearchListVM")
struct TestSearchListVM {

    // MARK: - SUT Factory

    func makeSUT(stubbedResult: Result<[SearchResult], Error> = .success([]), onSearchTap: @escaping (SearchResult) -> Void = { _ in }) -> (sut: SearchListVM, repository: TestMockJobRepository) {
        let repository = TestMockJobRepository()
        repository.stub(searchResults: stubbedResult)
        let sut = SearchListVM(onSearchTap: onSearchTap, repository: repository)
        return (sut, repository)
    }

    // MARK: - Initial State

    @Test("Initial state is idle with empty query")
    func initialState() {
        let (sut, _) = makeSUT()

        guard case .idle = sut.state.search else {
            Issue.record("Expected idle, got \(sut.state.search)")
            return
        }
        #expect(sut.state.searchQuery.isEmpty)
    }

    // MARK: - resetSearch

    @Test("resetSearch sets search state back to idle")
    func resetSearch() {
        let (sut, _) = makeSUT()
        sut.state.search = .loading

        sut.resetSearch()

        guard case .idle = sut.state.search else {
            Issue.record("Expected idle after reset, got \(sut.state.search)")
            return
        }
    }

    // MARK: - performSearch — query guard

    @Test("performSearch does nothing if query is empty")
    func performSearchEmptyQuery() async {
        let (sut, repository) = makeSUT()
        sut.state.searchQuery = ""

        await sut.performSearch()

        #expect(repository.searchResultFetch == false)
        guard case .idle = sut.state.search else {
            Issue.record("Expected idle, got \(sut.state.search)")
            return
        }
    }

    @Test("performSearch does nothing if query is only whitespace")
    func performSearchWhitespaceQuery() async {
        let (sut, repository) = makeSUT()
        sut.state.searchQuery = "   "

        await sut.performSearch()

        #expect(repository.searchResultFetch == false)
    }

    // MARK: - performSearch — success

    @Test("performSearch sets loaded state with results on success")
    func performSearchSuccess() async {
        let (sut, repository) = makeSUT(stubbedResult: .success(SearchResult.mockList))
        sut.state.searchQuery = "iOS"

        await sut.performSearch()

        #expect(repository.searchResultFetch)

        guard case .loaded(let loaded) = sut.state.search else {
            Issue.record("Expected loaded, got \(sut.state.search)")
            return
        }
        #expect(loaded.count == 2)
        #expect(loaded.map(\.id) == ["1", "3"])
    }

    @Test("performSearch sets loaded with empty array when no results")
    func performSearchEmptyResults() async {
        let (sut, _) = makeSUT(stubbedResult: .success([]))
        sut.state.searchQuery = "Cobol"

        await sut.performSearch()

        guard case .loaded(let results) = sut.state.search else {
            Issue.record("Expected loaded, got \(sut.state.search)")
            return
        }
        #expect(results.isEmpty)
    }

    // MARK: - performSearch — failure

    @Test("performSearch sets failed state on error")
    func performSearchFailure() async {
        struct TestError: Error, Equatable {}
        let (sut, _) = makeSUT(stubbedResult: .failure(TestError()))
        sut.state.searchQuery = "iOS"

        await sut.performSearch()

        guard case .failed(let error) = sut.state.search else {
            Issue.record("Expected failed, got \(sut.state.search)")
            return
        }
        #expect(error is TestError)
    }

    @Test("performSearch silently returns on CancellationError")
    func performSearchCancellationError() async {
        let (sut, _) = makeSUT(stubbedResult: .failure(CancellationError()))
        sut.state.searchQuery = "iOS"

        await sut.performSearch()

        // State stays at .loading — cancelled mid-flight, never reaches .failed
        guard case .loading = sut.state.search else {
            Issue.record("Expected loading after cancellation, got \(sut.state.search)")
            return
        }
    }

    // MARK: - reloadSearch

    @Test("reloadSearch resets to idle then fetches")
    func reloadSearchResetsAndFetches() async throws {
        let (sut, repository) = makeSUT(stubbedResult: .success(SearchResult.mockList))
        sut.state.searchQuery = "Swift"
        sut.state.search = .failed(NSError(domain: "test", code: 0))

        sut.reloadSearch()
        // State is reset synchronously before the task runs
        guard case .idle = sut.state.search else {
            Issue.record("Expected idle immediately after reloadSearch, got \(sut.state.search)")
            return
        }

        try await Task.sleep(for: .milliseconds(100))
        #expect(repository.searchResultFetch)
    }

    @Test("reloadSearch cancels prior searchTask before starting new one")
    func reloadSearchCancelsPriorTask() async throws {
        let (sut, repository) = makeSUT(stubbedResult: .success(SearchResult.mockList))
        sut.state.searchQuery = "iOS"

        sut.reloadSearch()
        sut.reloadSearch() // cancels first, starts second

        try await Task.sleep(for: .milliseconds(100))

        // Only one call completes
        #expect(repository.searchResultFetch)
    }

    // MARK: - performSearchDebounced

    @Test("performSearchDebounced waits 500ms before fetching")
    func performSearchDebouncedWaits() async throws {
        let (sut, repository) = makeSUT(stubbedResult: .success(SearchResult.mockList))
        sut.state.searchQuery = "iOS"

        sut.performSearchDebounced()

        // Should not have fired yet
        #expect(repository.searchResultFetch == false)

        try await Task.sleep(for: .milliseconds(600))
        #expect(repository.searchResultFetch == true)
    }

    @Test("performSearchDebounced cancels prior task on rapid calls")
    func performSearchDebouncedCancelsPriorTask() async throws {
        let (sut, repository) = makeSUT(stubbedResult: .success(SearchResult.mockList))
        sut.state.searchQuery = "iOS"

        sut.performSearchDebounced()
        try await Task.sleep(for: .milliseconds(100))
        sut.performSearchDebounced() // cancels the first
        try await Task.sleep(for: .milliseconds(100))
        sut.performSearchDebounced() // cancels the second

        try await Task.sleep(for: .milliseconds(600))

        // Only the last debounced call fires
        #expect(repository.searchResultFetch)
    }

    @Test("performSearchDebounced does not fetch if task cancelled before delay")
    func performSearchDebouncedCancelledBeforeDelay() async throws {
        let (sut, repository) = makeSUT(stubbedResult: .success(SearchResult.mockList))
        sut.state.searchQuery = "iOS"

        sut.performSearchDebounced()
        sut.searchTask?.cancel()

        try await Task.sleep(for: .milliseconds(600))

        #expect(repository.searchResultFetch == false)
    }

    // MARK: - onSearchTap callback

    @Test("onSearchTap is invoked with correct result")
    func onSearchTapCallback() {
        let expected = SearchResult.mock
        var received: SearchResult?

        let (sut, _) = makeSUT(onSearchTap: { received = $0 })
        sut.onSearchTap(expected)

        #expect(received?.id == "1")
    }
}
