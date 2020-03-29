//
//  Toy.swift
//  Relentless
//
//  Created by Chow Yi Yin on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
class ToyCar: AssembledItem {
    static let category = Category.toyCar
    static let toyCarHeader = "ToyCar: "
    static let partTypesAndFrequencies = [(PartType.wheel, 1),
                                          (PartType.battery, 1),
                                          (PartType.toyCarBody, 1)]

    init(wheel: ToyCarWheel, battery: ToyCarBattery, toyCarBody: ToyCarBody) {
        let toyCarParts = [wheel, battery, toyCarBody].sorted()
        super.init(parts: toyCarParts, category: ToyCar.category)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AssembledItemKeys.self)

        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AssembledItemKeys.self)
//        try container.encode(unsortedParts, forKey: .parts)
//        try container.encode(category, forKey: .category)

        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }

    override func equals(other: Item) -> Bool {
        guard let otherToyCar = other as? ToyCar else {
            return false
        }
        return otherToyCar.unsortedParts == self.unsortedParts
    }

    override func toString() -> String {
        var string = ToyCar.toyCarHeader
        for part in unsortedParts {
            string += "\n" + part.toString()
        }
        return string
    }
}
