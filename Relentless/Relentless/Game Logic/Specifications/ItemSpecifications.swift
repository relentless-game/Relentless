//
//  ItemSpecifications.swift
//  Relentless
//
//  Created by Chow Yi Yin on 12/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class ItemSpecifications {
    var availableGroupsOfItems: [Category: Set<[Item]>]
    var itemIdentifierMappings: [Category: [Int: String]]
    var partsToAssembledItemCategoryMapping: [[Category]: Category] //categories should be sorted
    
    init(availableGroupsOfItems: [Category: Set<[Item]>],
         itemIdentifierMappings: [Category: [Int: String]],
         partsToAssembledItemCategoryMapping: [[Category]: Category]) {
        self.availableGroupsOfItems = availableGroupsOfItems
        self.itemIdentifierMappings = itemIdentifierMappings
        self.partsToAssembledItemCategoryMapping = partsToAssembledItemCategoryMapping
    }
}
