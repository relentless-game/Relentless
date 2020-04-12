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
        let availableItems = [Category: Set<Item>]()
        let assembledItemCategories = [Category: [Category]]()
        let itemIdentifierMappings =  [Category: [Int: String]]()
        return ItemSpecifications(availableItems: availableItems,
                                  assembledItemCategories: assembledItemCategories,
                                  itemIdentifierMappings: itemIdentifierMappings)
    }
}
