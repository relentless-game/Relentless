//
//  ItemSpecificationsParser.swift
//  Relentless
//
//  Created by Chow Yi Yin on 12/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class ItemSpecificationsParser {
    // todo: implement
    static func parse() -> ItemSpecifications {
        let availableGroupsOfItems = [Category: Set<[Item]>]()
        let itemIdentifierMappings = [Category: [Int: String]]()
        let partsToAssembledItemCategoryMappings = [[Category]: Category]()
        return ItemSpecifications(availableGroupsOfItems: availableGroupsOfItems,
                                  itemIdentifierMappings: itemIdentifierMappings,
                                  partsToAssembledItemCategoryMapping: partsToAssembledItemCategoryMappings)
    }
}
