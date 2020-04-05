//
//  PartType.swift
//  Relentless
//
//  Created by Chow Yi Yin on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

enum PartType: Int, Codable, CaseIterable {
    case toyCarWheel
    case toyCarBattery
    case toyCarBody
    case partContainer // represents an assembled item

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PartTypeKeys.self)
        let rawValue = try container.decode(Int.self, forKey: .partType)
        switch rawValue {
        case PartType.toyCarWheel.rawValue:
            self = .toyCarWheel
        case PartType.toyCarBattery.rawValue:
            self = .toyCarBattery
        case PartType.toyCarBody.rawValue:
            self = .toyCarBody
        case PartType.partContainer.rawValue:
            self = .partContainer
        default:
            throw PartTypeError.unknownValue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PartTypeKeys.self)
        switch self {
        case .toyCarWheel:
            try container.encode(PartType.toyCarWheel.rawValue, forKey: .partType)
        case .toyCarBattery:
            try container.encode(PartType.toyCarBattery.rawValue, forKey: .partType)
        case .toyCarBody:
            try container.encode(PartType.toyCarBody.rawValue, forKey: .partType)
        case .partContainer:
            try container.encode(PartType.partContainer.rawValue, forKey: .partType)
        }
    }

    func toString() -> String {
        switch self {
        case .toyCarWheel:
            return "Toy Car Wheel"
        case .toyCarBattery:
            return "Toy Car Battery"
        case .toyCarBody:
            return "Toy Car Body"
        case .partContainer:
            return "Item Container"
        }
    }
}

enum PartTypeKeys: CodingKey {
    case partType
}

enum PartTypeError: Error {
    case unknownValue
}
