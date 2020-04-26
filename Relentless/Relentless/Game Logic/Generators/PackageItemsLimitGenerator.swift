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
            var assembledPartsCount = [Int]()
            for assembledItem in assembledItems {
                var count = 0
                for part in assembledItem.parts {
                    count += extractAllParts(item: part).count
                }
                assembledPartsCount.append(count)
            }
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

    private func extractAllParts(item: Item) -> [Item] {
        guard let assembledItem = item as? AssembledItem else {
            return [item]
        }
        var parts = [Item]()
        for part in assembledItem.parts {
            parts.append(contentsOf: extractAllParts(item: part))
        }
        return parts
    }

}
