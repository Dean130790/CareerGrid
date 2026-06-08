//
//  RootView.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import SwiftUI
import SwiftData

struct RootView: View {

    @State private var coordinator = NavigationCoordinator()
    @State private var appContainer = AppContainerFactory.make(environment: .current)

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            JobListView(viewModel: JobListVM(onJobTap: { job in
                coordinator.push(.jobDetail(source: JobDetailsSource.job(job)))
            }, onSearchTap: {
                coordinator.push(.search)
            }, repository: appContainer.jobRepository))
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .search:
                    SearchListView(viewModel: SearchListVM(onSearchTap: { result in
                        coordinator.push(.jobDetail(source: JobDetailsSource.search(result)))
                    }, repository: appContainer.jobRepository))
                case .jobDetail(let source):
                    JobDetailsView(viewModel: JobDetailsVM(source: source, repository: appContainer.jobRepository))
                }
            }
            .environment(coordinator)
        }
    }
}
