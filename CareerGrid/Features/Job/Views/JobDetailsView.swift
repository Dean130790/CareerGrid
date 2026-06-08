//
//  JobDetailsView.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import SwiftUI

public struct JobDetailsView: View {

    @State var viewModel: JobDetailsVM

    public var body: some View {
        jobDetailsContent
            .task {
                guard case .search = viewModel.source else { return }
                viewModel.reloadJobDetails()
            }
            .onDisappear {
                viewModel.fetchTask?.cancel()
            }
            .navigationTitle("Job Details")
    }

    @ViewBuilder
    private var jobDetailsContent: some View {
        if case .job(let job) = viewModel.source {
            scrollContent(job: job)
        } else {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
            case .loaded(let job):
                if let job = job {
                    scrollContent(job: job)
                } else {
                    AppContentUnavailableView.error()
                }
            case .failed(let error):
                AppContentUnavailableView.error(error, viewModel.reloadJobDetails)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func scrollContent(job: Job) -> some View {
        return ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                headerSection(job: job)

                Divider()

                salarySection(job: job)

                Divider()

                detailsSection(job: job)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func reloadJobDetails() {
        viewModel.reloadJobDetails()
    }
}


private extension JobDetailsView {

    func headerSection(job: Job) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(job.title)
                .font(.title)
                .fontWeight(.bold)

            Text(job.company.name)
                .font(.headline)

            Text(job.company.address)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    func salarySection(job: Job) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            Text("Salary")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(job.salaryRange)
                .font(.title3)
                .fontWeight(.semibold)
        }
    }

    func detailsSection(job: Job) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Job Description")
                .font(.headline)

            Text(job.jobDetails)
                .font(.body)
        }
    }
}
