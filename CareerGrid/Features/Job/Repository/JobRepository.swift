//
//  JobRepository.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

@MainActor
public final class JobRepository: JobRepositoryProtocol {
    
    private let remote: JobRemoteDataSourceProtocol
    private let local: JobLocalDataSourceProtocol
    
    public init(remote: JobRemoteDataSourceProtocol, local: JobLocalDataSourceProtocol) {
        self.remote = remote
        self.local = local
    }
    
    public func fetchJobs(page: Int, limit: Int, policy: CachePolicy) async throws -> JobResponse {
        switch policy {
        case .networkOnly:
            return try await fetchRemote(page: page, limit: limit)
            
        case .cacheFirst(let expiration):
            let expired = try isExpired(page: page, limit: limit, expiration: expiration)
            if !expired {
                let cached = try fetchLocal(page: page, limit: limit)
                if !cached.isEmpty {
                    return JobResponse(totalCount: -1, jobs: cached)
                }
            }
            
            do {
                return try await fetchRemote(page: page, limit: limit)
            } catch {
                let cached = try fetchLocal(page: page, limit: limit)
                if !cached.isEmpty {
                    return JobResponse(totalCount: -1, jobs: cached)
                }
                throw error
            }
            
        case .staleWhileRevalidate(let expiration):
            let cached = try fetchLocal(page: page, limit: limit)
            if !cached.isEmpty {
                Task { [weak self] in
                    guard let self else { return }
                    try? await self.refreshIfNeeded(page: page, limit: limit, expiration: expiration)
                }
                return JobResponse(totalCount: -1, jobs: cached)
            }
            return try await fetchRemote(page: page, limit: limit)
        }
    }
    
    public func searchJobs(query: String) async throws -> [SearchResult] {
        let dtos = try await remote.searchJobs(query: query)
        return dtos.map { $0.toDomain() }
    }
    
    public func fetchJobDetails(jobID: String) async throws -> Job? {
        if let dtos = try await remote.fetchJobDetails(jobID: jobID).first {
            return dtos.toDomain()
        }
        return nil
    }
}

private extension JobRepository {
    func fetchRemote(page: Int, limit: Int) async throws -> JobResponse {
        let dtos = try await remote.fetchJobs(page: page, limit: limit)
        try saveToLocal(jobDTOs: dtos.jobs)

        let jobs = dtos.jobs.map { $0.toDomain() }
        return JobResponse(totalCount: dtos.totalCount, jobs: jobs)
    }
    
    func saveToLocal(jobDTOs: [JobDTO]) throws {
        let entities = jobDTOs.map { $0.toEntity() }
        try local.saveJobs(entities)
    }
    
    func fetchLocal(page: Int, limit: Int) throws -> [Job] {
        let entities = try local.fetchJobs(page: page, limit: limit)
        let jobs = entities.map { $0.toDomain() }
        return jobs
    }
    
    func refreshIfNeeded(page: Int, limit: Int, expiration: TimeInterval) async throws {
        let expired = try isExpired(page: page, limit: limit, expiration: expiration)
        guard expired else {
            return
        }
        _ = try await fetchRemote( page: page, limit: limit)
    }
    
    func isExpired(page: Int, limit: Int, expiration: TimeInterval) throws -> Bool {
        guard let updatedAt = try local.lastUpdatedAt(page: page, limit: limit) else { return true}
        return Date().timeIntervalSince(updatedAt) > expiration
    }
}
