//
//  RhythmState.swift
//  Relentless
//
//  Created by Yi Wai Chow on 27/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

enum RhythmState: String, Codable, Comparable {

    case lit
    case unlit
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RhythmStateKeys.self)
        let rawValue = try container.decode(String.self, forKey: .rhythmState)
        switch rawValue {
        case RhythmState.lit.rawValue:
            self = .lit
        case RhythmState.unlit.rawValue:
            self = .unlit
        default:
            throw RhythmStateError.unknownValue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RhythmStateKeys.self)
        switch self {
        case .lit:
            try container.encode(RhythmState.lit.rawValue, forKey: .rhythmState)
        case .unlit:
            try container.encode(RhythmState.unlit.rawValue, forKey: .rhythmState)
        }
    }

    static func < (lhs: RhythmState, rhs: RhythmState) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    func toString() -> String {
        switch self {
        case .lit:
            return "Lit"
        case .unlit:
            return "Unlit"
        }
    }
}

enum RhythmStateKeys: CodingKey {
    case rhythmState
}

enum RhythmStateError: Error {
    case unknownValue
}
