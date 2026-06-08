//
//  SearchListView.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import SwiftUI

public struct SearchListView: View {

    @State private var viewModel: SearchListVM

    @FocusState private var isSearchFocused: Bool

    init(viewModel: SearchListVM) {
        self.viewModel = viewModel
    }

    public var body: some View {
        searchContent
            .navigationTitle("Search Jobs")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $viewModel.state.searchQuery,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Search coins"
            )
            .searchFocused($isSearchFocused)
            .onChange(of: viewModel.state.searchQuery) { oldValue, newValue in
                if newValue.isEmpty {
                    viewModel.state.search = .idle
                } else {
                    viewModel.performSearchDebounced()
                }
            }
            .onAppear {
                isSearchFocused = true
            }
            .onDisappear {
                viewModel.searchTask?.cancel()
            }
    }

    @ViewBuilder
    private var searchContent: some View {
        switch viewModel.state.search {
        case .idle:
            AppContentUnavailableView.searchDefault()
        case .loading:
            ProgressView()
        case .loaded(let results):
            if results.isEmpty {
                AppContentUnavailableView.noJobsFound(query: viewModel.state.searchQuery)
            } else {
                searchResultListView(results)
            }
        case .failed(let error):
            AppContentUnavailableView.error(error, viewModel.reloadSearch)
        }
    }

    private func searchCellView(_ result: SearchResult) -> some View {
        return SearchCellView(searchResult: result, onTap: viewModel.onSearchTap)
    }

    private func searchResultListView(_ results: [SearchResult]) -> some View {
        List(results) { result in
            searchCellView(result)
        }
    }
}
