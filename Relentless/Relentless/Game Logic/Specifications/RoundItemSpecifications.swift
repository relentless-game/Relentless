//
//  RoundItemSpecification.swift
//  Relentless
//
//  Created by Chow Yi Yin on 13/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
class RoundItemSpecifications: Codable {
    let partsToAssembledItemCategoryMapping: [[Category]: Category]

    init(partsToAssembledItemCategoryMapping: [[Category]: Category]) {
        self.partsToAssembledItemCategoryMapping = partsToAssembledItemCategoryMapping
    }
}
