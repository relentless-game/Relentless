//
//  Battery.swift
//  Relentless
//
//  Created by Chow Yi Yin on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
class ToyCarBattery: Part {
    static let partType = PartType.toyCarBattery
    static let category = ToyCar.category
    static let toyCarBatteryHeader = "Toy Car Battery: "

    var label: Label

    init(label: Label) {
        self.label = label
        super.init(category: ToyCarBattery.category, partType: ToyCarBattery.partType)
    }

    enum ToyCarBatteryKeys: CodingKey {
        case label
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ToyCarBatteryKeys.self)
        self.label = try container.decode(Label.self, forKey: .label)

        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ToyCarBatteryKeys.self)
        try container.encode(label, forKey: .label)
        try super.encode(to: encoder)
    }

    override func equals(other: Item) -> Bool {
        guard let otherBattery = other as? ToyCarBattery else {
            return false
        }
        return otherBattery.label == self.label
    }
    
    override func toString() -> String {
        ToyCarBattery.toyCarBatteryHeader + label.toString()
    }

    override func hash(into hasher: inout Hasher) {
        hasher.combine(partType)
        hasher.combine(label)
    }

    override func isLessThan(other: Item) -> Bool {
        guard let otherBattery = other as? ToyCarBattery else {
            return false
        }
        if self.partType.rawValue < otherBattery.partType.rawValue {
            return true
        } else if self.partType.rawValue > otherBattery.partType.rawValue {
            return false
        } else {
            let lowerCasedLabel = self.label.toString().lowercased()
            let otherLowerCasedLabel = otherBattery.label.toString().lowercased()
            return lowerCasedLabel.lexicographicallyPrecedes(otherLowerCasedLabel)
        }
    }
}
