//
//  Part.swift
//  Relentless
//
//  Created by Chow Yi Yin on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
class Part: Hashable, Codable {

    var partType: PartType

    init(partType: PartType) {
        self.partType = partType
    }

    static func == (lhs: Part, rhs: Part) -> Bool {
        if lhs.partType != rhs.partType {
            return false
        }
        return lhs.equals(other: rhs)
    }

    /// These methods below should be overriden by subclasses
    func equals(other: Part) -> Bool {
        false
    }

    func toString() -> String {
        "Part"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(partType)
    }

    func isLessThan(other: Part) -> Bool {
        false
    }
}

extension Part: Comparable {
    static func < (lhs: Part, rhs: Part) -> Bool {
        if lhs.partType != rhs.partType {
            return lhs.partType.rawValue < rhs.partType.rawValue
        }
        return lhs.isLessThan(other: rhs)
    }
}
