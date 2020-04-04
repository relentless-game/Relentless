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
    static let partTypesAndFrequencies = [(PartType.toyCarWheel, 1),
                                          (PartType.toyCarBattery, 1),
                                          (PartType.toyCarBody, 1)]

    init(wheel: ToyCarWheel, battery: ToyCarBattery, toyCarBody: ToyCarBody) {
        let toyCarParts = [wheel, battery, toyCarBody].sorted()
        super.init(parts: toyCarParts, category: ToyCar.category)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
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
            string += " " + part.toString()
        }
        return string
    }
}
