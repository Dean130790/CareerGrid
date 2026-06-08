//
//  Loadable.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

public enum Loadable<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(Error)
}
