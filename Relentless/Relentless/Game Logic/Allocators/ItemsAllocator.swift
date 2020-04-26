//
//  ItemsAllocator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// This class represents an allocator that generates items
/// based on the given categories and allocates them to the given players.
class ItemsAllocator: GameItemsAllocator {
    
    /// Generates items based on the given categories and allocates them to the given players
    func allocateItems(inventoryItems: [Item], to players: [Player]) {
        var itemsToAssign = inventoryItems
        let numberOfItemsForEachPlayer = Int((Float(itemsToAssign.count) / Float(players.count)))
        for player in players {
            while player.items.count < numberOfItemsForEachPlayer {
                let itemToAllocate = getRandomItem(from: itemsToAssign)
                guard let indexOfAllocatedItem = itemsToAssign.firstIndex(of: itemToAllocate) else {
                    continue
                }
                player.items.insert(itemToAllocate)
                itemsToAssign.remove(at: indexOfAllocatedItem)
            }
        }
        // randomly assign remaining items
        while !itemsToAssign.isEmpty {
            allocateToRandomPlayer(players: players, item: itemsToAssign[0])
            itemsToAssign.remove(at: 0)
        }
    }

    private func getRandomItem(from list: [Item]) -> Item {
        let indexRange = 0...(list.count - 1)
        let randomIndex = Int.random(in: indexRange)
        return list[randomIndex]
    }

    /// Chooses a random player and allocates the item to that player
    private func allocateToRandomPlayer(players: [Player], item: Item) {
        let playerIndexRange = 0...(players.count - 1)
        let randomPlayer = players[Int.random(in: playerIndexRange)]
        randomPlayer.items.insert(item)
    }

}
