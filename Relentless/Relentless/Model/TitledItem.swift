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

    init(name: String, category: Category, isInventoryItem: Bool,
         isOrderItem: Bool, imageString: String) {
        self.name = name
        super.init(itemType: .titledItem, category: category, isInventoryItem: isInventoryItem,
                   isOrderItem: isOrderItem, imageString: imageString)
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

    /// Other item should be of type TitledItem and should have the same category as this object
    override func isLessThan(other: Item) -> Bool {
        guard let otherItem = other as? TitledItem else {
            assertionFailure("other item should be of type TitledItem")
            return false
        }
        assert(otherItem.category == self.category)
        let lowerCasedName = self.name.lowercased()
        let otherLowerCasedName = otherItem.name.lowercased()
        return lowerCasedName.lexicographicallyPrecedes(otherLowerCasedName)
    }

    override func hash(into hasher: inout Hasher) {
        hasher.combine(category)
        hasher.combine(name)
    }
    
    override func toString() -> String {
        name
    }

    override func equals(other: Item) -> Bool {
        guard let otherItem = other as? TitledItem else {
            return false
        }
        return self.category == otherItem.category &&
            self.name == otherItem.name
    }
}

enum TitledItemKeys: CodingKey {
    case name
}
