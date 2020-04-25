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

    // for assembledItems
    var assembledItemImageRepresentationMapping: [Category: ImageRepresentation]
    var partsToAssembledItemCategoryMapping: [[Category]: Category] //categories should be sorted

    init(availableGroupsOfItems: [Category: Set<[Item]>],
         assembledItemImageRepresentationMapping: [Category: ImageRepresentation],
         partsToAssembledItemCategoryMapping: [[Category]: Category]) {
        self.availableGroupsOfItems = availableGroupsOfItems
        self.assembledItemImageRepresentationMapping = assembledItemImageRepresentationMapping
        self.partsToAssembledItemCategoryMapping = partsToAssembledItemCategoryMapping
    }
}
