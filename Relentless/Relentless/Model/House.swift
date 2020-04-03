//
//  House.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class House {

    /// Ranges from 0 (non-inclusive) to 1 (inclusive)
    var satisfactionFactor: Float

    var orders: Set<Order> {
        didSet {
            NotificationCenter.default.post(name: .didOrderUpdateInHouse, object: nil)
        }
    }

    var activeOrders: [Order] {
        orders.filter { $0.hasStarted }
    }

    init(orders: Set<Order>, satisfactionFactor: Float) {
        assert(satisfactionFactor > 0 && satisfactionFactor <= 1)
        self.orders = orders
        self.satisfactionFactor = satisfactionFactor
        NotificationCenter.default.addObserver(self, selector: #selector(notifyOrderUpdate(notification:)),
                                               name: .didTimeUpdateInOrder, object: nil)
    }

    /// Returns true if the package correctly matches any of the active orders
    func checkPackage(package: Package) -> Bool {
        for order in activeOrders where order.checkPackage(package: package) {
            return true
        }
        return false
    }

    /// Returns the order with the fewest number of differences from the package.
    /// If the package has same number of differences from two orders,
    /// the order with a smaller timeLeft will be returned.
    /// Return value will only be nil if orders set is empty
    func getClosestOrder(for package: Package) -> Order? {
        var minNumberOfDifferences = Order.MAX_NUMBER_OF_ITEMS + 1
        var orderWithMinDifferences = orders.first
        for order in activeOrders {
            let numberOfDifferences = order.getNumberOfDifferences(with: package)
            let hasFewerDifferences = numberOfDifferences < minNumberOfDifferences

            guard let timeLeftForOrderWithMinDifference = orderWithMinDifferences?.timeLeft else {
                continue
            }
            let hasSameNumberOfDifferencesButShorterTime = numberOfDifferences == minNumberOfDifferences
                && order.timeLeft < timeLeftForOrderWithMinDifference

            let orderShouldBeFulfilled = hasFewerDifferences || hasSameNumberOfDifferencesButShorterTime
            if orderShouldBeFulfilled {
                minNumberOfDifferences = numberOfDifferences
                orderWithMinDifferences = order
            }
        }
        return orderWithMinDifferences
    }

    func removeOrder(order: Order) {
        orders.remove(order)
        order.stopTimer()
    }

    @objc
    func notifyOrderUpdate(notification: Notification) {
        NotificationCenter.default.post(name: .didOrderUpdateInHouse, object: nil)
    }
}
