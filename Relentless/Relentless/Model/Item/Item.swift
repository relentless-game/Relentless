//
//  Item.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class Item: Hashable, Codable {
    var category: Category

    // only used for encoding and decoding purposes (not included to check equivalence)
    var itemType: ItemType

    // only important for item generation purposes (not included to check equivalence)
    var isInventoryItem: Bool
    var isOrderItem: Bool

    // only important for view representation (not included to check equivalence)
    var imageRepresentation: ImageRepresentation

    init(itemType: ItemType, category: Category, isInventoryItem: Bool, isOrderItem: Bool,
         imageRepresentation: ImageRepresentation) {
        self.itemType = itemType
        self.category = category
        self.isInventoryItem = isInventoryItem
        self.isOrderItem = isOrderItem
        self.imageRepresentation = imageRepresentation
    }

    static func == (lhs: Item, rhs: Item) -> Bool {
        let isSameTypeOfItem = lhs.category == rhs.category
        if !isSameTypeOfItem {
            return false
        }
        return lhs.equals(other: rhs)
    }
    
    /// These methods below should be overriden by subclasses
    func equals(other: Item) -> Bool {
        self.category == other.category
    }

    func isLessThan(other: Item) -> Bool {
        self.category < other.category
    }

    func toString() -> String {
        "Item"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(category)
    }
}

extension Item: Comparable {
    
    /// Items are first sorted by category and then sorted within each category
    static func < (lhs: Item, rhs: Item) -> Bool {
        if lhs.category.categoryName < rhs.category.categoryName {
            return true
        } else if lhs.category.categoryName > rhs.category.categoryName {
            return false
        } else {
            return lhs.isLessThan(other: rhs)
        }
    }
}
