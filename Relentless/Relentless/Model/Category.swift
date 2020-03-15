//
//  Category.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

enum Category: Int, Codable {
<<<<<<< HEAD
    case book
    case magazine
=======
    case BOOK
    case MAGAZINE
>>>>>>> master

    enum CategoryKeys: CodingKey {
        case category
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CategoryKeys.self)
        let rawValue = try container.decode(Int.self, forKey: .category)
        switch rawValue {
<<<<<<< HEAD
        case Category.book.rawValue:
            self = .book
        case Category.magazine.rawValue:
            self = .magazine
=======
        case Category.BOOK.rawValue:
            self = .BOOK
        case Category.MAGAZINE.rawValue:
            self = .MAGAZINE
>>>>>>> master
        default:
            throw CategoryError.unknownValue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CategoryKeys.self)
        switch self {
<<<<<<< HEAD
        case .book:
            try container.encode(Category.book.rawValue, forKey: .category)
        case .magazine:
            try container.encode(Category.magazine.rawValue, forKey: .category)
=======
        case .BOOK:
            try container.encode(Category.BOOK.rawValue, forKey: .category)
        case .MAGAZINE:
            try container.encode(Category.MAGAZINE.rawValue, forKey: .category)
>>>>>>> master
        }
    }
}

enum CategoryError: Error {
    case unknownValue
}
