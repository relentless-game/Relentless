//
//  Titled.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class TitledItem: Item {
    var name: String

    init(name: String, category: Category) {
        self.name = name
        super.init(category: category)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TitledItemKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TitledItemKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)

        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }
    
    override func isLessThan(other: Item) -> Bool {
        guard let otherItem = other as? TitledItem else {
            return false
        }
        if self.category.rawValue < otherItem.category.rawValue {
            return true
        } else if self.category.rawValue == otherItem.category.rawValue {
            return !self.name.lexicographicallyPrecedes(otherItem.name)
        } else {
            return false
        }
    }

    override func hash(into hasher: inout Hasher) {
        hasher.combine(category)
        hasher.combine(name)
    }
}

enum TitledItemKeys: CodingKey {
    case name
    case category
}
