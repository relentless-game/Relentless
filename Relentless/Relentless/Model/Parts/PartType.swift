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
        let container = try decoder.container(keyedBy: PartTypeKeys.self)
        let rawValue = try container.decode(Int.self, forKey: .partType)
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
        var container = encoder.container(keyedBy: PartTypeKeys.self)
        switch self {
        case .wheel:
            try container.encode(PartType.wheel.rawValue, forKey: .partType)
        case .battery:
            try container.encode(PartType.battery.rawValue, forKey: .partType)
        case .toyCarBody:
            try container.encode(PartType.toyCarBody.rawValue, forKey: .partType)
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

enum PartTypeKeys: CodingKey {
    case partType
}

enum PartTypeError: Error {
    case unknownValue
}
