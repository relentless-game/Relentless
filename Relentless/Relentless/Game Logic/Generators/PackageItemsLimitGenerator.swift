//
//  PackageItemsLimitGenerator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 4/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// Generates the limit for the number of items in a package
class PackageItemsLimitGenerator {

    let orders: [Order]
    let probabilityOfHavingLimit: Double

    init(orders: [Order], probabilityOfHavingLimit: Double) {
        self.orders = orders
        self.probabilityOfHavingLimit = probabilityOfHavingLimit
    }

    /// Generates a limit on the number of items in a package
    /// based on the orders and the probability of imposing a limit
    func generateItemsLimit() -> Int? {
        let randomNumber = Double.random(in: 0...1)
        guard randomNumber <= probabilityOfHavingLimit else {
            return nil
        }
        
        return calculateLimit()
    }

    private func calculateLimit() -> Int? {
        let minForEachOrder = orders.map {
            let assembledItems = $0.items.compactMap { $0 as? AssembledItem }
            let assembledPartsCount = assembledItems.map { $0.parts.count }
            guard let maxPartCount = assembledPartsCount.max() else {
                return $0.items.count
            }
            return $0.items.count - 1 + maxPartCount
        } as [Int]

        guard let maxOfOrders = minForEachOrder.max() else {
            return nil
        }

        let limit = max(maxOfOrders, orders.count)

        return limit
    }

}
