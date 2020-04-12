//
//  GameItemGenerator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol GameItemGenerator {

    /// Generates the items and returns an array of inventory items and an array of order items
    func generate(categories: [Category]) -> ([Item], [Item])

}
