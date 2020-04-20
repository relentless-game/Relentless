//
//  Item.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class Item: Hashable, Codable {

    var itemType: ItemType
    var category: Category
    var isInventoryItem: Bool
    var isOrderItem: Bool

    init(itemType: ItemType, category: Category, isInventoryItem: Bool, isOrderItem: Bool) {
        self.itemType = itemType
        self.category = category
        self.isInventoryItem = isInventoryItem
        self.isOrderItem = isOrderItem
    }

    static func == (lhs: Item, rhs: Item) -> Bool {
        let isSameTypeOfItem = lhs.category == rhs.category &&
            lhs.isInventoryItem == rhs.isInventoryItem &&
            lhs.isOrderItem == rhs.isOrderItem
        if !isSameTypeOfItem {
            return false
        }
        return lhs.equals(other: rhs)
    }
    
    /// These methods below should be overriden by subclasses
    func equals(other: Item) -> Bool {
        false
    }

    func isLessThan(other: Item) -> Bool {
        false
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
