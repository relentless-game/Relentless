//
//  StatefulItem.swift
//  Relentless
//
//  Created by Chow Yi Yin on 11/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// A `StatefulItem` is an item which can be in one of a finite number of distinct states.
/// Each item is identified by the index of the state that it is in.
class StatefulItem: Item {
    let stateIdentifier: Int

    init(category: Category, stateIdentifier: Int, isInventoryItem: Bool,
         isOrderItem: Bool, imageRepresentation: ImageRepresentation) {
        self.stateIdentifier = stateIdentifier
        super.init(itemType: .statefulItem, category: category, isInventoryItem: isInventoryItem,
                   isOrderItem: isOrderItem, imageRepresentation: imageRepresentation)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StatefulItemKeys.self)
        self.stateIdentifier = try container.decode(Int.self, forKey: .stateIdentifier)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StatefulItemKeys.self)
        try container.encode(stateIdentifier, forKey: .stateIdentifier)
        try super.encode(to: encoder)
    }
    
    override func isLessThan(other: Item) -> Bool {
        if self.category.categoryName < other.category.categoryName {
            return true
        } else if self.category.categoryName > other.category.categoryName {
            return false
        } else {
            guard let otherItem = other as? StatefulItem else {
                return false
            }
            return self.stateIdentifier < otherItem.stateIdentifier
        }
    }

    override func hash(into hasher: inout Hasher) {
        hasher.combine(category)
        hasher.combine(stateIdentifier)
    }

    override func toString() -> String {
        ""
    }

    override func equals(other: Item) -> Bool {
        guard let otherItem = other as? StatefulItem else {
            return false
        }
        return self.category == otherItem.category &&
            self.stateIdentifier == otherItem.stateIdentifier
    }
}

enum StatefulItemKeys: CodingKey {
    case stateIdentifier
}
