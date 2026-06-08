//
//  SearchCellView.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import SwiftUI

struct SearchCellView: View {
    
    let searchResult: SearchResult
    let onTap: (SearchResult) -> Void
    
    var body: some View {
        Button {
            onTap(searchResult)
        } label: {
            
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                
                Text(searchResult.jobTitle)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                Text(searchResult.companyDetails.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}
