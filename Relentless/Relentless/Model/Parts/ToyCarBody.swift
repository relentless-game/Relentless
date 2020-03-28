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
    static let toyCarHeader = "Toy Car Body: "

    var colour: Colour

    init(colour: Colour) {
        self.colour = colour
        super.init(partType: ToyCarBody.partType)
    }

    enum ToyCarBodyKeys: CodingKey {
        case colour
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ToyCarBodyKeys.self)
        self.colour = try container.decode(Colour.self, forKey: .colour)

        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ToyCarBodyKeys.self)
        try container.encode(colour, forKey: .colour)

        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }

    override func equals(other: Part) -> Bool {
        guard let otherToyCarBody = other as? ToyCarBody else {
            return false
        }
        return otherToyCarBody.colour == self.colour
    }

    override func toString() -> String {
        ToyCarBody.toyCarHeader + colour.rawValue
    }

    override func hash(into hasher: inout Hasher) {
        hasher.combine(partType)
        hasher.combine(colour)
    }

    override func isLessThan(other: Part) -> Bool {
        guard let otherToyCarBody = other as? ToyCarBody else {
            return false
        }
        if self.partType.rawValue < otherToyCarBody.partType.rawValue {
            return true
        } else if self.partType.rawValue == otherToyCarBody.partType.rawValue {
            return !self.colour.rawValue.lexicographicallyPrecedes(otherToyCarBody.colour.rawValue)
        } else {
            return false
        }
    }
}
