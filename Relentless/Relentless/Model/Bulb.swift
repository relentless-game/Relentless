//
//  Bulb.swift
//  Relentless
//
//  Created by Yi Wai Chow on 27/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class Bulb: RhythmicItem {
    static let category = Category.bulb
    static let bulbHeader = "Bulb: "

    init(unitDuration: Int, stateSequence: [RhythmState]) {
        super.init(unitDuration: unitDuration, stateSequence: stateSequence, category: Bulb.category)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RhythmicItemKeys.self)
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RhythmicItemKeys.self)
        try container.encode(unitDuration, forKey: .unitDuration)
        try container.encode(stateSequence, forKey: .stateSequence)
        try container.encode(category, forKey: .category)

        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }

    override func equals(other: Item) -> Bool {
        guard let otherBulb = other as? Bulb else {
            return false
        }
        return otherBulb.unitDuration == self.unitDuration
            && otherBulb.stateSequence == self.stateSequence
    }

    override func toString() -> String {
        Bulb.bulbHeader + String(unitDuration) + stateSequence.description
    }
}
