//
//  PaginationState.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

public struct PaginationState<Item> {
    public var content: Loadable<[Item]> = .idle
    public var currentPage = 1
    public var totalPages = 0
    public var isLoadingNextPage = false

    public init() {}
}
