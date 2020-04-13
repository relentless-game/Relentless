//
//  ItemSpecifications.swift
//  Relentless
//
//  Created by Chow Yi Yin on 12/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class ItemSpecifications {
    static var availableGroupsOfItems: [Category: Set<[Item]>] = [:]
    static var itemIdentifierMappings: [Category: [Int: String]] = [:]
    static var partsToAssembledItemCategoryMapping: [[Category]: Category] = [:]
}
