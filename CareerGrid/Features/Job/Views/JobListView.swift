//
//  JobListView.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import SwiftUI

public struct JobListView: View {

    @State private var viewModel: JobListVM

    init(viewModel: JobListVM) {
        self.viewModel = viewModel
    }


    public var body: some View {
        jobContent
            .navigationTitle("Jobs")
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.onSearchTap()
                    } label: {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                }
            })
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewModel.reloadJobs()
            }
            .refreshable {
                viewModel.refreshJobs()
            }
            .onDisappear {
                viewModel.fetchTask?.cancel()
            }
    }

    @ViewBuilder
    private var jobContent: some View {
        switch viewModel.state.content {
        case .idle, .loading:
            ProgressView()
        case .loaded(let jobs):
            if jobs.isEmpty {
                AppContentUnavailableView.noItemsFound()
            } else {
                jobListView(jobs)
            }
        case .failed(let error):
            AppContentUnavailableView.error(error, viewModel.reloadJobs)
        }
    }

    private func jobCellView(_ job: Job) -> some View {
        return JobCellView(job: job, onTap: viewModel.onJobTap)
    }

    private func jobListView(_ jobs: [Job]) -> some View {
        paginatedList(jobs, shouldShowPagination: viewModel.state.currentPage < viewModel.state.totalPages) { job in
            jobCellView(job)
        }
    }

    private func paginatedList<Data, Row>(_ items: [Data], shouldShowPagination: Bool, @ViewBuilder row: @escaping (Data) -> Row) -> some View where Data: Identifiable, Row: View {
        List {
            ForEach(items) { item in
                row(item)
            }

            if shouldShowPagination {
                paginationFooter
            }
        }
    }

    @ViewBuilder
    private var paginationFooter: some View {
        paginationFooterView(viewModel.state.currentPage) {
            await viewModel.loadNextFeedPage()
        }
    }

    @ViewBuilder
    private func paginationFooterView(_ currentPage: Int, action: @escaping () async -> Void) -> some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .id(currentPage)
        .onAppear {
            Task {
                await action()
            }
        }
    }
}
