//
//  Category.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

enum Category: Int, Codable, CaseIterable {
    case book
    case magazine

    enum CategoryKeys: CodingKey {
        case category
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CategoryKeys.self)
        let rawValue = try container.decode(Int.self, forKey: .category)
        switch rawValue {
        case Category.book.rawValue:
            self = .book
        case Category.magazine.rawValue:
            self = .magazine
        default:
            throw CategoryError.unknownValue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CategoryKeys.self)
        switch self {
        case .book:
            try container.encode(Category.book.rawValue, forKey: .category)
        case .magazine:
            try container.encode(Category.magazine.rawValue, forKey: .category)
        }
    }
}

enum CategoryError: Error {
    case unknownValue
}
