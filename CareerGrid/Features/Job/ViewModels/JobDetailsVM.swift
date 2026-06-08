//
//  JobDetailsVM.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation
import Observation

@MainActor
@Observable
class JobDetailsVM {

    var state: Loadable<Job?> = .idle
    var fetchTask: Task<Void, Never>?

    let source: JobDetailsSource
    private let repository: JobRepositoryProtocol

    init(source: JobDetailsSource, repository: JobRepositoryProtocol) {
        self.source = source
        self.repository = repository
    }

    func reloadJobDetails() {
        fetchTask?.cancel()
        fetchTask = Task {
            await fetchJobDetails()
        }
    }

    func fetchJobDetails() async {
        state = .loading
        guard case .search(let result) = source else { return }
        do {
            let job = try await repository.fetchJobDetails(jobID: result.id)
            guard !Task.isCancelled else { return }
            state = .loaded(job)
        } catch is CancellationError {
            return
        } catch {
            state = .failed(error)
        }
    }
}
