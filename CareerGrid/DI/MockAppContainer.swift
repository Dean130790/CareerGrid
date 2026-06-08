//
//  MockAppContainer.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import NetworkingKit

final class MockAppContainer: AppContainer {
    static let shared = MockAppContainer()

    public let httpClient: HTTPClient
    public let persistence: PersistenceContainer
    public let jobRepository: JobRepositoryProtocol


    private init() {
        self.persistence = PersistenceContainer(inMemory: true)
        let localDataSource = MockJobLocalDataSource()

        self.httpClient = MockHTTPClient()
        let remoteDataSource = MockJobRemoteDataSource()

        self.jobRepository = JobRepository(remote: remoteDataSource, local: localDataSource)
    }
}
