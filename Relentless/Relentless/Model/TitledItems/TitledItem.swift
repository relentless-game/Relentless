//
//  TitledItem.swift
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
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TitledItemKeys.self)
        try container.encode(name, forKey: .name)
        try super.encode(to: encoder)
    }
    
    override func isLessThan(other: Item) -> Bool {
        guard let otherItem = other as? TitledItem else {
            return false
        }
        if self.category.rawValue < otherItem.category.rawValue {
            return true
        } else if self.category.rawValue > otherItem.category.rawValue {
            return false
        } else {
            let lowerCasedName = self.name.lowercased()
            let otherLowerCasedName = otherItem.name.lowercased()
            return lowerCasedName.lexicographicallyPrecedes(otherLowerCasedName)
        }
    }

    override func hash(into hasher: inout Hasher) {
        hasher.combine(category)
        hasher.combine(name)
    }
    
    override func toString() -> String {
        "TitledItem"
    }
}

enum TitledItemKeys: CodingKey {
    case name
    case category
}
