//
//  AppContainer.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation
import NetworkingKit

protocol AppContainer {
    var httpClient: HTTPClient { get }
    var persistence: PersistenceContainer { get }
    var jobRepository: JobRepositoryProtocol { get }
}
