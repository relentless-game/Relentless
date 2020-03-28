//
//  Battery.swift
//  Relentless
//
//  Created by Chow Yi Yin on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
class Battery: Part {
    static let partType = PartType.battery
    static let batteryHeader = "Battery: "

    var label: String

    init(label: String) {
        self.label = label
        super.init(partType: Battery.partType)
    }

    enum BatteryKeys: CodingKey {
        case label
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BatteryKeys.self)
        self.label = try container.decode(String.self, forKey: .label)

        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: BatteryKeys.self)
        try container.encode(label, forKey: .label)

        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }

    override func equals(other: Part) -> Bool {
        guard let otherBattery = other as? Battery else {
            return false
        }
        return otherBattery.label == self.label
    }
    
    override func toString() -> String {
        Battery.batteryHeader + label
    }

    override func hash(into hasher: inout Hasher) {
        hasher.combine(partType)
        hasher.combine(label)
    }

    override func isLessThan(other: Part) -> Bool {
        guard let otherBattery = other as? Battery else {
            return false
        }
        if self.partType.rawValue < otherBattery.partType.rawValue {
            return true
        } else if self.partType.rawValue == otherBattery.partType.rawValue {
            return !self.label.lexicographicallyPrecedes(otherBattery.label)
        } else {
            return false
        }
    }
}
