//
//  Category.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// Represents a category of items.
struct Category: Codable, Hashable {
    
    let categoryName: String
    
    init(name: String) {
        self.categoryName = name
    }
}

extension Category: Comparable {
    static func < (lhs: Category, rhs: Category) -> Bool {
        lhs.categoryName.lexicographicallyPrecedes(rhs.categoryName)
    }
}
