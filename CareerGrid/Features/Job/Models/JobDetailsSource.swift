//
//  JobDetailsSource.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

public enum JobDetailsSource: Hashable {
    case job(Job)
    case search(SearchResult)
}
