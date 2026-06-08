
//
//  JobRemoteDataSource.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation
import NetworkingKit

public protocol JobRemoteDataSourceProtocol: Sendable {
    func fetchJobs(page: Int, limit: Int) async throws -> JobResponseDTO
    func searchJobs(query: String) async throws -> [SearchResultDTO]
    func fetchJobDetails(jobID: String) async throws -> [JobDTO]
}

public final class JobRemoteDataSource: JobRemoteDataSourceProtocol, Sendable {

    private let networkManager: NetworkManager

    public init(httpClient: HTTPClient) {
        let baseURL = URL(string: "")!
        self.networkManager = NetworkManager(client: httpClient, baseURL: baseURL)
    }

    public func fetchJobs(page: Int, limit: Int) async throws -> JobResponseDTO {
        return try await networkManager.request(
            endpoint: JobEndpoint.jobs(page: page),
            responseType: JobResponseDTO.self
        )
    }

    public func searchJobs(query: String) async throws -> [SearchResultDTO] {
        return try await networkManager.request(
            endpoint: JobEndpoint.search(query: query),
            responseType: [SearchResultDTO].self
        )
    }

    public func fetchJobDetails(jobID: String) async throws -> [JobDTO] {
        return try await networkManager.request(
            endpoint: JobEndpoint.jobDetails(id: jobID),
            responseType: [JobDTO].self
        )
    }
}
