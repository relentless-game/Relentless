//
//  Package.swift
//  Relentless
//
//  Created by Liu Zechu on 13/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class Package {
    let creator: String /// user name of the player that created this package
    let packageNumber: Int
    var items = [Item]()
    
    init(creator: String, packageNumber: Int, items: [Item]) {
        self.creator = creator
        self.packageNumber = packageNumber
        self.items = items
    }
}
