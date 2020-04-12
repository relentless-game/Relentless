//
//  GameItemGenerator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol GameEntityGenerator {

    /// Generates the items and returns an array of inventory items and an array of orders
    func generate(categories: [Category]) -> ([Item], [Order])

}
