//
//  Item.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class Item: Hashable, Comparable, Codable {

    var category: Category

    init(category: Category) {
        self.category = category
    }

    static func < (lhs: Item, rhs: Item) -> Bool {
        if lhs.category != rhs.category {
            return lhs.category.rawValue < rhs.category.rawValue
        }
        return lhs.isLessThan(other: rhs)
    }

    static func ==(lhs: Item, rhs: Item) -> Bool {
        if lhs.category != rhs.category {
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

    func hash(into hasher: inout Hasher) {
        hasher.combine(category)
    }

} 
