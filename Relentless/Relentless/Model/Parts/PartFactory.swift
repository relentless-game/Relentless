//
//  PartFactory.swift
//  Relentless
//
//  Created by Liu Zechu on 21/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// This is a wrapper class that contains an array of items of heterogeneous types.
class PartFactory: Codable {
    let parts: [Part]

    init(parts: [Part]) {
        self.parts = parts
    }

    enum PartFactoryKeys: CodingKey {
        case parts
    }

    enum PartFactoryTypeKeys: CodingKey {
        case partType
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PartFactoryKeys.self)
        try container.encode(parts, forKey: .parts)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PartFactoryKeys.self)
        var partsArrayForType = try container.nestedUnkeyedContainer(forKey: PartFactoryKeys.parts)
        var parts = [Part]()
        var partsArray = partsArrayForType
        while !partsArrayForType.isAtEnd {
            let part = try partsArrayForType.nestedContainer(keyedBy: PartFactoryTypeKeys.self)
            let type = try part.decode(PartType.self, forKey: PartFactoryTypeKeys.partType)
            switch type {
            case .toyCarWheel:
                parts.append(try partsArray.decode(ToyCarWheel.self))
            case .toyCarBattery:
                parts.append(try partsArray.decode(ToyCarBattery.self))
            case .toyCarBody:
                parts.append(try partsArray.decode(ToyCarBody.self))
            default:
                continue
            }
        }
        self.parts = parts
    }
}
