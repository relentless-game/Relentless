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

    func toImageString() -> String {
        var colour: Colour?
        var label: Label?
        var shape: Shape?
        for part in unsortedParts {
            switch part.partType {
            case .toyCarBattery:
                label = (part as? ToyCarBattery)?.label
            case .toyCarBody:
                colour = (part as? ToyCarBody)?.colour
            case .toyCarWheel:
                shape = (part as? ToyCarWheel)?.shape
            case .partContainer:
                assert(false)
            }
        }
        guard colour != nil, label != nil, shape != nil else {
            return ""
        }
        // Force as all are not nil
        let string = "toycar_whole_\(colour!.toString())_\(shape!.toString())_\(label!.toString())"
        return string
    }

    override func toDisplayString() -> String {
        ""
    }
}
