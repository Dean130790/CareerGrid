//
//  MockLoader.swift
//  CareerGrid
//
//  Created by Yatharth Wadekar on 07/06/26.
//

import Foundation

enum MockLoader {
    static func load<T: Decodable>(filename: String, type: T.Type) throws -> T {
        let bundle = Bundle.main
        guard let url = bundle.url(forResource: filename, withExtension: "json") else { fatalError("Missing mock file: \(filename)")}
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
