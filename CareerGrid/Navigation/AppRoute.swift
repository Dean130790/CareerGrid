//
//  AppRoute.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

enum AppRoute: Hashable {
    case search
    case jobDetail(source: JobDetailsSource)
}
