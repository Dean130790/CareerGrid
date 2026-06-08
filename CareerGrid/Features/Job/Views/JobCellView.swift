//
//  JobCellView.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import SwiftUI

struct JobCellView: View {
    
    let job: Job
    let onTap: (Job) -> Void
    
    var body: some View {
        Button {
            onTap(job)
        } label: {
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(job.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(job.company.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(job.company.address)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}
