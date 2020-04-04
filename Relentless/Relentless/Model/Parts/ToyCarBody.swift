//
//  ToyCarBody.swift
//  Relentless
//
//  Created by Chow Yi Yin on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class ToyCarBody: Part {
    static let partType = PartType.toyCarBody
    static let category = ToyCar.category
    static let toyCarBodyHeader = "Toy Car Body: "

    var colour: Colour

    init(colour: Colour) {
        self.colour = colour
        super.init(category: ToyCarBody.category, partType: ToyCarBody.partType)
    }

    enum ToyCarBodyKeys: CodingKey {
        case colour
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ToyCarBodyKeys.self)
        self.colour = try container.decode(Colour.self, forKey: .colour)
        
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ToyCarBodyKeys.self)
        try container.encode(colour, forKey: .colour)
        try super.encode(to: encoder)
    }

    override func equals(other: Item) -> Bool {
        guard let otherToyCarBody = other as? ToyCarBody else {
            return false
        }
        return otherToyCarBody.colour == self.colour
    }

    override func toString() -> String {
        ToyCarBody.toyCarBodyHeader + colour.rawValue
    }

    override func hash(into hasher: inout Hasher) {
        hasher.combine(partType)
        hasher.combine(colour)
    }

    override func isLessThan(other: Item) -> Bool {
        guard let otherToyCarBody = other as? ToyCarBody else {
            return false
        }
        if self.partType.rawValue < otherToyCarBody.partType.rawValue {
            return true
        } else if self.partType.rawValue > otherToyCarBody.partType.rawValue {
            return false
        } else {
            return self.colour.rawValue.lexicographicallyPrecedes(otherToyCarBody.colour.rawValue)
        }
    }
}
