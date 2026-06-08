//
//  SearchResultState.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//


import Foundation

@MainActor
@Observable
final class SearchResultState {
    var search: Loadable<[SearchResult]> = .idle
    var searchQuery = ""
}
