//
//  OrdersAllocator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class OrdersAllocator: GameOrdersAllocator {

    var difficultyLevel: Float // ranges from 0 (easiest) to 1 (most difficult)

    var defaultNumOfOrders: Int = 5 // per player
    var defaultMaxNumOfItems: Int = 3 // per order; update to use static variable in `Order`
    var defaultTimeLimit: Int = 30 // in seconds

    init(difficultyLevel: Float) {
        self.difficultyLevel = difficultyLevel
    }

    func allocateOrders(players: [Player]) {
        let numOfOrders = defaultNumOfOrders + Int(difficultyLevel * Float(defaultNumOfOrders))
        let maxNumOfItems = defaultMaxNumOfItems + Int(difficultyLevel * Float(defaultMaxNumOfItems))
        for player in players {
            while player.orders.count < numOfOrders {
                let order = generateOrder(maxNumOfItems: maxNumOfItems, currPlayer: player, allPlayers: players)
                player.orders.insert(order)
            }
        }
    }

    private func generateOrder(maxNumOfItems: Int, currPlayer: Player, allPlayers: [Player]) -> Order {
        let numberOfItems = Int.random(in: 1...maxNumOfItems)

        // choose player's own items for half of the order
        let numberOfOwnItems = numberOfItems / 2
        let selectedOwnItems = selectItems(from: currPlayer.items, numberToSelect: numberOfOwnItems)
        // choose other players' items as remaining items for order
        let othersItems = extractOthersItems(currPlayer: currPlayer, allPlayers: allPlayers)
        let selectedOthersItems = selectItems(from: othersItems,
                                              numberToSelect: numberOfItems - numberOfOwnItems)
        var allSelectedItems = [Item]()
        allSelectedItems.append(contentsOf: selectedOwnItems)
        allSelectedItems.append(contentsOf: selectedOthersItems)

        let order = Order(items: allSelectedItems, timeLimitInSeconds: defaultTimeLimit)
        return order
    }

    /// Randomly choose `numberToSelect` items from given items
    private func selectItems(from items: Set<Item>, numberToSelect: Int) -> [Item] {
        // to prevent getting stuck in an infinite loop below
        guard !items.isEmpty else {
            return []
        }
        
        var selectedItems = [Item]()
        while selectedItems.count < numberToSelect {
            guard let randomItem = items.randomElement() else {
                continue
            }
            selectedItems.append(randomItem)
        }
        return selectedItems
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
