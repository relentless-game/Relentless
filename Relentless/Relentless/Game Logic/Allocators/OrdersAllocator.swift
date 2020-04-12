//
//  OrdersAllocator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class OrdersAllocator: GameOrdersAllocator {

    var difficultyLevel: Float

    var maxNumOfItemsPerOrder: Int
    var numOfOrdersPerPlayer: Int
    var probabilityOfSelectingOwnItem: Float

    init(difficultyLevel: Float, maxNumOfItemsPerOrder: Int, numOfOrdersPerPlayer: Int,
         probabilityOfSelectingOwnItem: Float) {
        self.difficultyLevel = difficultyLevel
        self.maxNumOfItemsPerOrder = maxNumOfItemsPerOrder
        self.numOfOrdersPerPlayer = numOfOrdersPerPlayer
        self.probabilityOfSelectingOwnItem = probabilityOfSelectingOwnItem
    }

    func allocateOrders(orderItems: [Item], to players: [Player]) {
        let orderItems = orderItems.filter { $0.isOrderItem }
        for player in players {
            while player.orders.count < numOfOrdersPerPlayer {
                let order = generateOrder(maxNumOfItems: maxNumOfItemsPerOrder, currPlayer: player,
                                          allPlayers: players, orderItems: orderItems)
                player.orders.insert(order)
            }
        }
    }

    private func generateOrder(maxNumOfItems: Int, currPlayer: Player, allPlayers: [Player],
                               orderItems: [Item]) -> Order {
        let numberOfItems = Int.random(in: 1...maxNumOfItems)
        let selectedItems = selectItems(numberOfItems: numberOfItems, currPlayer: currPlayer,
                                        allPlayers: allPlayers)
        let timeAllocated = selectedItems.count * GameHostParameters.timeForEachItem
        let order = Order(items: selectedItems, timeLimitInSeconds: timeAllocated)
        return order
    }

//    private func convertToAssembledItem(parts: [Part], items: [Item], numberOfPlayers: Int) -> [AssembledItem] {
//        let assembledItems = items.compactMap { $0 as? AssembledItem }
//        var selectedAssembledItems = Set<AssembledItem>()
//        for part in parts {
//            let randomNumber = Float.random(in: 0...1)
//            if randomNumber <= GameHostParameters.probabilityOfSelectingAssembledItem(numberOfPlayers:
//                numberOfPlayers) {
//                for assembledItem in assembledItems where assembledItem.parts.contains(part) {
//                    selectedAssembledItems.insert(assembledItem)
//                }
//            }
//            for assembledItem in assembledItems where assembledItem.parts.contains(part) {
//                selectedAssembledItems.insert(assembledItem)
//            }
//        }
//        return Array(selectedAssembledItems)
//    }

    private func selectItems(numberOfItems: Int, currPlayer: Player, allPlayers: [Player]) -> [Item] {
        var selectedItems = [Item]()
        let othersItems = extractOthersItems(currPlayer: currPlayer, allPlayers: allPlayers)

        while selectedItems.count < numberOfItems {
            let randomNumber = Float.random(in: 0...1)
            if randomNumber <= probabilityOfSelectingOwnItem {
                guard let selectedItem = selectRandomItem(from: currPlayer.items) else {
                    continue
                }
                selectedItems.append(selectedItem)
            } else {
                guard let selectedItem = selectRandomItem(from: othersItems) else {
                    continue
                }
                selectedItems.append(selectedItem)
            }
        }

        return selectedItems
    }

    private func selectRandomItem(from items: Set<Item>) -> Item? {
        guard let randomItem = items.randomElement() else {
            return nil
        }
        return randomItem
    }

    /// Extracts and combines the items of all other players 
    private func extractOthersItems(currPlayer: Player, allPlayers: [Player]) -> Set<Item> {
        var othersItems = [Item]()
        for player in allPlayers where player != currPlayer {
            othersItems.append(contentsOf: player.items)
        }
        return Set(othersItems)
    }
}