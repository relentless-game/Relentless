//
//  House.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

struct House {
    var orders: Set<Order>

    init(orders: Set<Order>) {
        self.orders = orders
    }

    /// Returns the order that matches the package and returns nil if none matches
    func checkPackage(package: Package) -> Order? {
        for order in orders where order.checkPackage(package: package) {
            return order
        }
        return nil
    }

    /// Returns the order with the fewest number of differences from the package. Return value will only be nil if orders set is empty
    func getClosestOrder(for package: Package) -> Order? {
        var minNumberOfDifferences = Order.MAX_NUMBER_OF_ITEMS + 1
        var orderWithMinDifferences = orders.first
        for order in orders {
            let numberOfDifferences = order.getNumberOfDifferences(with: package)
            let hasFewerDifferences = numberOfDifferences < minNumberOfDifferences

            guard let timeLimitForOrderWithMinDifference = orderWithMinDifferences?.timeLimit else {
                continue
            }
            let hasSameNumberOfDifferencesButShorterTime = numberOfDifferences == minNumberOfDifferences
                && order.timeLimit < timeLimitForOrderWithMinDifference

            let orderShouldBeFulfilled = hasFewerDifferences || hasSameNumberOfDifferencesButShorterTime
            if orderShouldBeFulfilled {
                minNumberOfDifferences = numberOfDifferences
                orderWithMinDifferences = order
            }
        }
        return orderWithMinDifferences
    }

}
