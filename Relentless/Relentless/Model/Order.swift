//
//  Order.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class Order: Hashable {

    var timeLeft: Int = 0 // change initial value
    var timeLimit: Int = 0 // change initial value

    init(items: [Item], timeLimit: Int) {
        // to implement
    }

    static func == (lhs: Order, rhs: Order) -> Bool {
        // to change
        return true
    }

    func hash(into hasher: inout Hasher) {
        // to change
    }

}
