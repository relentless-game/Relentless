//
//  Wheel.swift
//  Relentless
//
//  Created by Chow Yi Yin on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class ToyCarWheel: Part {
    static let partType = PartType.toyCarWheel
    static let category = ToyCar.category
    static let toyCarWheelHeader = "Toy Car Wheel: "

    var shape: Shape

    init(shape: Shape) {
        self.shape = shape
        super.init(category: ToyCarWheel.category, partType: ToyCarWheel.partType)
    }

    enum ToyCarWheelKeys: CodingKey {
        case shape
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ToyCarWheelKeys.self)
        self.shape = try container.decode(Shape.self, forKey: .shape)

        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ToyCarWheelKeys.self)
        try container.encode(shape, forKey: .shape)

        try super.encode(to: encoder)
    }

    override func equals(other: Item) -> Bool {
        guard let otherWheel = other as? ToyCarWheel else {
            return false
        }
        return otherWheel.shape == self.shape
    }

    override func toString() -> String {
        ToyCarWheel.toyCarWheelHeader + shape.toString()
    }

    override func hash(into hasher: inout Hasher) {
        hasher.combine(partType)
        hasher.combine(shape)
    }

    override func isLessThan(other: Item) -> Bool {
        guard let otherWheel = other as? ToyCarWheel else {
            return false
        }
        if self.partType.rawValue < otherWheel.partType.rawValue {
            return true
        } else if self.partType.rawValue == otherWheel.partType.rawValue {
            return self.shape.rawValue.lexicographicallyPrecedes(otherWheel.shape.rawValue)
        } else {
            return false
        }
    }
}
