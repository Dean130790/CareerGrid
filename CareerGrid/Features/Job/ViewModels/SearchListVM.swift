//
//  SearchListVM.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation
import Observation

@MainActor
@Observable
class SearchListVM {

    var state: SearchResultState = .init()

    var searchTask: Task<Void, Never>?

    let onSearchTap: (SearchResult) -> Void

    private var hasFetched = false

    let repository: JobRepositoryProtocol


    public init(onSearchTap: @escaping (SearchResult) -> Void, repository: JobRepositoryProtocol) {
        self.onSearchTap = onSearchTap
        self.repository = repository
    }

    func resetSearch() {
        state.search = .idle
    }

    func reloadSearch() {
        resetSearch()

        searchTask?.cancel()
        searchTask = Task {
            await performSearch()
        }
    }

    func performSearchDebounced() {
        searchTask?.cancel()
        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(500))
                guard !Task.isCancelled else { return }
                await performSearch()
            } catch is CancellationError {
                return
            } catch {
                return
            }
        }
    }

    func performSearch() async {
        let query = state.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        if query.isEmpty { return }

        state.search = .loading

        do {
            let results = try await repository.searchJobs(query: query)
            guard !Task.isCancelled else { return }
            state.search = .loaded(results)
        } catch is CancellationError {
            return
        } catch {
            state.search = .failed(error)
        }
    }
}
