//
//  JobListVM.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation
import Observation

@MainActor
@Observable
class JobListVM {

    var state = PaginationState<Job>()
    var fetchTask: Task<Void, Never>?

    let onJobTap: (Job) -> Void
    let onSearchTap: () -> Void

    private var hasFetched = false

    let repository: JobRepositoryProtocol


    public init(onJobTap: @escaping (Job) -> Void, onSearchTap: @escaping () -> Void, repository: JobRepositoryProtocol) {
        self.onJobTap = onJobTap
        self.onSearchTap = onSearchTap
        self.repository = repository
    }

    func resetJobs() {
        state = .init()
    }

    func reloadJobs() {
        guard !hasFetched else { return }

        resetJobs()
        fetchTask?.cancel()
        fetchTask = Task {
            await fetchJobs(policy: .staleWhileRevalidate(expiration: 5 * 60))// 5min
        }
    }

    func refreshJobs() {
        state.currentPage = 1
        fetchTask?.cancel()
        fetchTask = Task {
            await fetchJobs(policy: .networkOnly)
        }
    }

    func totalPages(totalCount: Int, pageSize: Int = 20) -> Int {
        hasFetched = true

        let pageCount = totalCount > 0 ? Int(ceil(Double(totalCount) / Double(pageSize))) : 0
        return pageCount
    }

    func fetchJobs(policy: CachePolicy) async {
        state.content = .loading

        do {
            let jobResponse = try await repository.fetchJobs(page: state.currentPage, limit: 20, policy: policy)
            guard !Task.isCancelled else { return }
            state.content = .loaded(jobResponse.jobs)
            state.totalPages = totalPages(totalCount: jobResponse.totalCount)
        } catch is CancellationError {
            return
        } catch {
            state.content = .failed(error)
        }
    }

    func loadNextFeedPage() async {
        guard !state.isLoadingNextPage else { return }

        state.isLoadingNextPage = true
        defer { state.isLoadingNextPage = false }

        do {
            let nextPage = state.currentPage + 1

            let jobResponse = try await repository.fetchJobs(page: nextPage, limit: 20, policy: .staleWhileRevalidate(expiration: 5 * 60))// 5min

            guard case .loaded(let existing) = state.content else { return }

            state.content = .loaded(existing + jobResponse.jobs)
            state.currentPage = nextPage

        } catch is CancellationError {
            return
        } catch {
            state.content = .failed(error)
        }
    }
}
