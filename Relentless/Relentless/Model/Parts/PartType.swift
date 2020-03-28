//
//  PartType.swift
//  Relentless
//
//  Created by Chow Yi Yin on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

enum PartType: Int, Codable, CaseIterable {
    case wheel
    case battery
    case toyCarBody

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CategoryKeys.self)
        let rawValue = try container.decode(Int.self, forKey: .category)
        switch rawValue {
        case PartType.wheel.rawValue:
            self = .wheel
        case PartType.battery.rawValue:
            self = .battery
        case PartType.toyCarBody.rawValue:
            self = .toyCarBody
        default:
            throw PartTypeError.unknownValue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CategoryKeys.self)
        switch self {
        case .wheel:
            try container.encode(PartType.wheel.rawValue, forKey: .category)
        case .battery:
            try container.encode(PartType.battery.rawValue, forKey: .category)
        case .toyCarBody:
            try container.encode(PartType.toyCarBody.rawValue, forKey: .category)
        }
    }

    func toString() -> String {
        switch self {
        case .wheel:
            return "Book"
        case .battery:
            return "Magazine"
        case .toyCarBody:
            return "Toy Car"
        }
    }
}

enum PartKeys: CodingKey {
    case category
}

enum PartTypeError: Error {
    case unknownValue
}
