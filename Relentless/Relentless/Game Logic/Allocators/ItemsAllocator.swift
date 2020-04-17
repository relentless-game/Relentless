//
//  ItemsAllocator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class ItemsAllocator: GameItemsAllocator {
    /// Generates items based on the given categories and allocates them to the given players
//    func allocateItems(categories: [Category], players: [Player], items: [Items])
//        allocateItems(items: Array(inventoryItems), to: players)

//        let nonAssembledItems = allItems.filter { ($0 as? AssembledItem) == nil }
//        allocateNonAssembledItems(items: nonAssembledItems, to: players)
//
//        let assembledItems = allItems.compactMap { $0 as? AssembledItem }
//        allocateParts(items: assembledItems, to: players)

//        return Array(allItems)
//    }

//    private func allocateParts(items: [AssembledItem], to players: [Player]) {
//        var partsToAllocate = Array(Set(items.flatMap { $0.unsortedParts }))
//        let numberOfPartsForEachPlayer = Int((Float(partsToAllocate.count) / Float(players.count)))
//        for player in players {
//            let initialItemCount = player.items.count
//            while player.items.count < numberOfPartsForEachPlayer + initialItemCount {
//                let partToAllocate = getRandomItem(from: partsToAllocate)
//                guard let indexOfAllocatedPart = partsToAllocate.firstIndex(of: partToAllocate) else {
//                    continue
//                }
//                player.items.insert(partToAllocate)
//                partsToAllocate.remove(at: indexOfAllocatedPart)
//            }
//        }
//        // randomly assign remaining parts
//        while !partsToAllocate.isEmpty {
//            allocateToRandomPlayer(players: players, item: items[0])
//            partsToAllocate.remove(at: 0)
//        }
//    }

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
