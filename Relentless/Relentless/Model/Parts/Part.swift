//
//  Part.swift
//  Relentless
//
//  Created by Chow Yi Yin on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
class Part: Item {
    var partType: PartType

    init(category: Category, partType: PartType) {
        self.partType = partType
        super.init(category: category)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PartKeys.self)
        self.partType = try container.decode(PartType.self, forKey: .partType)

        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PartKeys.self)
        try container.encode(partType, forKey: .partType)
        
        try super.encode(to: encoder)
    }

    static func == (lhs: Part, rhs: Part) -> Bool {
        if lhs.partType != rhs.partType {
            return false
        }
        return lhs.equals(other: rhs)
    }

    /// These methods below should be overriden by subclasses
    override func equals(other: Item) -> Bool {
        false
    }

    override func toString() -> String {
        "Part"
    }

    override func hash(into hasher: inout Hasher) {
        hasher.combine(partType)
    }

    func isLessThan(other: Part) -> Bool {
        false
    }

    /// This method should be overriden by subclasses
    override func isLessThan(other: Item) -> Bool {
        false
    }
}

enum PartKeys: CodingKey {
    case partType
    case category
}
