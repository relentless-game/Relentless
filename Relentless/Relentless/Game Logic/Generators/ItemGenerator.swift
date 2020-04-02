//
//  ItemGenerator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 15/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol ItemGenerator {

    static func generateItems(category: Category, numberToGenerate: Int) -> [Item]
    
}
