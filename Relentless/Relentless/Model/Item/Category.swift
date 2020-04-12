//
//  Category.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

enum Category: String, Codable, CaseIterable, Hashable {
    case book
    case magazine
    case toyCar
    case wheel
    case carBody
    case battery
    case robot

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CategoryKeys.self)
        let rawValue = try container.decode(String.self, forKey: .category)
        switch rawValue {
        case Category.book.rawValue:
            self = .book
        case Category.magazine.rawValue:
            self = .magazine
        case Category.toyCar.rawValue:
            self = .toyCar
        case Category.wheel.rawValue:
            self = .wheel
        case Category.carBody.rawValue:
            self = .carBody
        case Category.battery.rawValue:
            self = .battery
        case Category.robot.rawValue:
            self = .robot
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
        case .toyCar:
            try container.encode(Category.toyCar.rawValue, forKey: .category)
        case .wheel:
            try container.encode(Category.wheel.rawValue, forKey: .category)
        case .carBody:
            try container.encode(Category.carBody.rawValue, forKey: .category)
        case .battery:
            try container.encode(Category.battery.rawValue, forKey: .category)
        case .robot:
            try container.encode(Category.robot.rawValue, forKey: .category)
        }
    }

    func toString() -> String {
        rawValue
    }
}

extension Category: Comparable {
    static func < (lhs: Category, rhs: Category) -> Bool {
        lhs.rawValue.lexicographicallyPrecedes(rhs.rawValue)
    }
}

enum CategoryKeys: CodingKey {
    case category
}

enum CategoryError: Error {
    case unknownValue
}
