//
//  JobState.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

final class JobState {
    var jobs = PaginationState<Job>()
    var searchResults = PaginationState<Job>()
    var jobDetails: Loadable<Job?> = .idle
}
