//
//  LiveAppContainer.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation
import SwiftData
import NetworkingKit

final class LiveAppContainer: AppContainer {
    static let shared = LiveAppContainer()

    public let httpClient: HTTPClient
    public let persistence: PersistenceContainer
    public let jobRepository: JobRepositoryProtocol

    private init() {

        self.persistence = PersistenceContainer()
        let localDataSource = JobLocalDataSource(context: persistence.container.mainContext)

        self.httpClient = URLSessionHTTPClient(session: .shared)
        let remoteDataSource = JobRemoteDataSource(httpClient: httpClient)

        self.jobRepository = JobRepository(remote: remoteDataSource, local: localDataSource)
    }
}
