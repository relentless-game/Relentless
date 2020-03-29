//
//  Wheel.swift
//  Relentless
//
//  Created by Chow Yi Yin on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class ToyCarWheel: Part {
    static let partType = PartType.wheel
    static let category = ToyCar.category
    static let toyCarWheelHeader = "Toy Car Wheel: "

    var radius: Double

    init(radius: Double) {
        self.radius = radius
        super.init(category: ToyCarWheel.category, partType: ToyCarWheel.partType)
    }

    enum ToyCarWheelKeys: CodingKey {
        case radius
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ToyCarWheelKeys.self)
        self.radius = try container.decode(Double.self, forKey: .radius)

        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ToyCarWheelKeys.self)
        try container.encode(radius, forKey: .radius)

        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }

    override func equals(other: Item) -> Bool {
        guard let otherWheel = other as? ToyCarWheel else {
            return false
        }
        return otherWheel.radius == self.radius
    }

    override func toString() -> String {
        ToyCarWheel.toyCarWheelHeader + String(radius)
    }

    override func hash(into hasher: inout Hasher) {
        hasher.combine(partType)
        hasher.combine(radius)
    }

    override func isLessThan(other: Item) -> Bool {
        guard let otherWheel = other as? ToyCarWheel else {
            return false
        }
        if self.partType.rawValue < otherWheel.partType.rawValue {
            return true
        } else if self.partType.rawValue == otherWheel.partType.rawValue {
            return self.radius < otherWheel.radius
        } else {
            return false
        }
    }
}
