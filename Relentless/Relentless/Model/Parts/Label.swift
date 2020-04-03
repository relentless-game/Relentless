//
//  Label.swift
//  Relentless
//
//  Created by Chow Yi Yin on 2/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
enum Label: String, Codable, CaseIterable {
    case d = "D"
    case aa = "AA"
    case pp3 = "PP3"

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: LabelKeys.self)
        let rawValue = try container.decode(String.self, forKey: .label)
        switch rawValue {
        case Label.d.rawValue:
            self = .d
        case Label.aa.rawValue:
            self = .aa
        case Label.pp3.rawValue:
            self = .pp3
        default:
            throw LabelError.unknownValue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: LabelKeys.self)
        switch self {
        case .d:
            try container.encode(Label.d.rawValue, forKey: .label)
        case .aa:
            try container.encode(Label.aa.rawValue, forKey: .label)
        case .pp3:
            try container.encode(Label.pp3.rawValue, forKey: .label)
        }
    }

    func toString() -> String {
        return self.rawValue
    }
}

enum LabelKeys: CodingKey {
    case label
}

enum LabelError: Error {
    case unknownValue
}
