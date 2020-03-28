//
//  Wheel.swift
//  Relentless
//
//  Created by Chow Yi Yin on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class Wheel: Part {
    static let partType = PartType.wheel
    static let wheelHeader = "Wheel: "

    var radius: Double

    init(radius: Double) {
        self.radius = radius
        super.init(partType: Wheel.partType)
    }

    enum WheelKeys: CodingKey {
        case radius
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: WheelKeys.self)
        self.radius = try container.decode(Double.self, forKey: .radius)

        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: WheelKeys.self)
        try container.encode(radius, forKey: .radius)

        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }

    override func equals(other: Part) -> Bool {
        guard let otherWheel = other as? Wheel else {
            return false
        }
        return otherWheel.radius == self.radius
    }

    override func toString() -> String {
        Wheel.wheelHeader + String(radius)
    }

    override func hash(into hasher: inout Hasher) {
        hasher.combine(partType)
        hasher.combine(radius)
    }

    override func isLessThan(other: Part) -> Bool {
        guard let otherWheel = other as? Wheel else {
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
