//
//  ErrorView.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import SwiftUI

@MainActor
public enum AppContentUnavailableView {
    public static func error(_ error: Error, _ action: @escaping @MainActor () -> Void, ) -> some View {
        ContentUnavailableView {
            Label("Something went wrong", systemImage: "tray.fill")
        } description: {
            Text(error.localizedDescription)
        } actions: {
            Button("Reload") {
                action()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    public static func error() -> some View {
        ContentUnavailableView(
            "Job Listing Unavailable",
            systemImage: "exclamationmark.triangle",
            description: Text("We can't seem to load this position right now. The opening may have been filled or closed by the company.")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    public static func noItemsFound() -> some View {
        ContentUnavailableView(
            "No Openings Right Now",
            systemImage: "briefcase",
            description: Text("There are no job listings available at the moment. Companies update their boards frequently, so please check back soon!")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    public static func noJobsFound(query: String) -> some View {
        ContentUnavailableView(
            "No Matching Jobs",
            systemImage: "briefcase.fll",
            description: Text("We scanned all job titles and company profiles but found no matches for \"\(query)\".")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    public static func searchDefault() -> some View {
        ContentUnavailableView(
            "Start Your Search",
            systemImage: "doc.text.magnifyingglass",
            description: Text("Type a job title, role, or company name to explore open opportunities.")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
