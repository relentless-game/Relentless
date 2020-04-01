//
//  Colour.swift
//  Relentless
//
//  Created by Chow Yi Yin on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

enum Colour: String, Codable, CaseIterable {
    case blue
    case red
    case green

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColourKeys.self)
        let rawValue = try container.decode(String.self, forKey: .colour)
        switch rawValue {
        case Colour.blue.rawValue:
            self = .blue
        case Colour.red.rawValue:
            self = .red
        case Colour.green.rawValue:
            self = .green
        default:
            throw ColourError.unknownValue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ColourKeys.self)
        switch self {
        case .blue:
            try container.encode(Colour.blue.rawValue, forKey: .colour)
        case .red:
            try container.encode(Colour.red.rawValue, forKey: .colour)
        case .green:
            try container.encode(Colour.green.rawValue, forKey: .colour)
        }
    }

    func toString() -> String {
        switch self {
        case .blue:
            return "blue"
        case .red:
            return "red"
        case .green:
            return "green"
        }
    }
}

enum ColourKeys: CodingKey {
    case colour
}

enum ColourError: Error {
    case unknownValue
}
