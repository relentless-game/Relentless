//
//  ItemSpecifications.swift
//  Relentless
//
//  Created by Chow Yi Yin on 12/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class ItemSpecifications {
    let availableItems: [Category: Set<Item>]
    let assembledItemCategories: [Category: [Category]]
    let itemIdentifierMappings: [Category: [Int: String]]

    var partsToAssembledItemCategoryMapping: [[Category]: Category] {
        var mapping = [[Category]: Category]()
        for category in assembledItemCategories.keys {
            guard let categoriesOfParts = assembledItemCategories[category] else {
                continue
            }
            mapping[categoriesOfParts] = category
        }
        return mapping
    }

    init(availableItems: [Category: Set<Item>], assembledItemCategories: [Category: [Category]], itemIdentifierMappings: [Category: [Int: String]]) {
        self.availableItems = availableItems
        self.assembledItemCategories = assembledItemCategories
        self.itemIdentifierMappings = itemIdentifierMappings
    }

}
