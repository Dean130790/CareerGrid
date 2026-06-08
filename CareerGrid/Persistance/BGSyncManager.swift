//
//  Untitled.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import BackgroundTasks

final class BGSyncManager {

    static let identifier = "com.salariasales.careergrid.CareerGrid"
    static let shared = BGSyncManager()

    func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: BGSyncManager.identifier, using: nil) { task in
            self.handleRefresh(task: task as! BGAppRefreshTask)
        }
    }

    private func handleRefresh(task: BGAppRefreshTask) {

        scheduleRefresh()

        let refreshTask = Task {
            do {
                _ = try await LiveAppContainer.shared.jobRepository.fetchJobs(page: 1, limit: 20, policy: .networkOnly)
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = { refreshTask.cancel() }
    }

    func scheduleRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: BGSyncManager.identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)// 15min

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print(error.localizedDescription)
        }
    }
}
