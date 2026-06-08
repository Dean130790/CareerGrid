//
//  JobRepository.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

@MainActor
public protocol JobRepositoryProtocol {
    func fetchJobs(page: Int, limit: Int, policy: CachePolicy) async throws -> JobResponse
    func searchJobs(query: String) async throws -> [SearchResult]
    func fetchJobDetails(jobID: String) async throws -> Job?
}

public enum CachePolicy {
    case networkOnly
    case cacheFirst(expiration: TimeInterval)
    case staleWhileRevalidate(expiration: TimeInterval)
}
