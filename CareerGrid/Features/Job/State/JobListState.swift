//
//  JobListState.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

@MainActor
@Observable
final class JobListState {
    var jobs = PaginationState<Job>()
}


