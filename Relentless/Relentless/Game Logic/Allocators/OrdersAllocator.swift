//
//  OrdersAllocator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class OrdersAllocator: GameOrdersAllocator {

    var maxNumOfItemsPerOrder: Int
    var numOfOrdersPerPlayer: Int
    var probabilityOfSelectingAssembledItem: Double
    var timeForEachItem: Int

    init(maxNumOfItemsPerOrder: Int, numOfOrdersPerPlayer: Int, probabilityOfSelectingAssembledItem: Double,
         timeForEachItem: Int) {
        self.maxNumOfItemsPerOrder = maxNumOfItemsPerOrder
        self.numOfOrdersPerPlayer = numOfOrdersPerPlayer
        self.probabilityOfSelectingAssembledItem = probabilityOfSelectingAssembledItem
        self.timeForEachItem = timeForEachItem
    }

    func allocateOrders(orderItems: [Item], to players: [Player]) {
        let orderItems = orderItems.filter { $0.isOrderItem }
        let numberOfPossibleUniqueOrders = Int(truncating: NSDecimalNumber(decimal: pow(2, orderItems.count))) - 1 //exclude empty order
        if numberOfPossibleUniqueOrders < numOfOrdersPerPlayer * players.count {
            numOfOrdersPerPlayer = numberOfPossibleUniqueOrders
        }
        let assembledItems = orderItems.compactMap { $0 as? AssembledItem }
        for player in players {
            while player.orders.count < numOfOrdersPerPlayer {
                let order = generateOrder(orderItems: orderItems, maxNumOfItems: maxNumOfItemsPerOrder,
                                          assembledItems: assembledItems)
                player.orders.insert(order)
            }
        }
    }

    /// Selects required number of items and creates an order
    private func generateOrder(orderItems: [Item], maxNumOfItems: Int,
                               assembledItems: [AssembledItem]) -> Order {
        let numberOfItems = Int.random(in: 1...maxNumOfItems)
        let selectedItems = selectItems(orderItems: orderItems, numberOfItems: numberOfItems,
                                        assembledItems: assembledItems)
        let timeAllocated = selectedItems.count * timeForEachItem
        let order = Order(items: selectedItems, timeLimitInSeconds: timeAllocated)
        return order
    }

    private func selectItems(orderItems: [Item], numberOfItems: Int,
                             assembledItems: [AssembledItem]) -> [Item] {
        var selectedItems = [Item]()

        while selectedItems.count < numberOfItems {
            guard let selectedItem = selectRandomItem(from: Set(orderItems)) else {
                continue
            }
            if !selectedItem.isOrderItem {
                // Selected item could be a part of an assembled item 
                guard let assembledItem = convertToAssembledItem(part: selectedItem,
                                                                 assembledItems: assembledItems) else {
                                                                    continue
                }
                selectedItems.append(assembledItem)
            } else {
                selectedItems.append(selectedItem)
            }
        }
        return selectedItems
    }

    /// Uses probability to decide whether or not convert to assembled item.
    /// If choose to convert, converts a part to an assembled item if the assembled item that contains part exists
    private func convertToAssembledItem(part: Item, assembledItems: [AssembledItem]) -> Item? {
        let assembledItemsThatContainPart = assembledItems.filter { $0.parts.contains(part) }
        let randomNumber = Double.random(in: 0...1)
        if randomNumber > probabilityOfSelectingAssembledItem ||
            assembledItemsThatContainPart.isEmpty {
            return nil
        }
        return selectRandomItem(from: Set(assembledItemsThatContainPart))
    }

    private func selectRandomItem(from items: Set<Item>) -> Item? {
        guard let randomItem = items.randomElement() else {
            return nil
        }
        return randomItem
    }
}
