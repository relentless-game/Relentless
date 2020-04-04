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
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }

    override func equals(other: Item) -> Bool {
        guard let otherBulb = other as? Bulb else {
            return false
        }
        return otherBulb.unitDuration == self.unitDuration
            && otherBulb.stateSequence == self.stateSequence
    }

    override func toString() -> String {
        "Bulb.bulbHeader + String(unitDuration) + stateSequence.description"
    }

    override func toDisplayString() -> String {
        ""
    }
}
