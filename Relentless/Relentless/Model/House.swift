//
//  House.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

struct House {
    var orders: [Order]

    init(orders: [Order]) {
        self.orders = orders
    }

    /// Returns true if package matches items in order
    func checkPackage(package: Package) -> Bool {
        for order in orders where order.checkPackage(package: package) {
            return true
        }
        return false
    }
}
