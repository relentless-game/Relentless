//
//  Order.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

struct Order {
    var items: [Item]
    var timer: Timer

    init(items: [Item], timer: Timer) {
        self.items = items.sorted()
        self.timer = timer
    }

    /// Returns true if package matches items in order
    func checkPackage(package: Package) -> Bool {
        let sortedPackage = package.sort()
        return sortedPackage.items == items
    }
}
