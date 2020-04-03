//
//  ItemsAllocator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class ItemsAllocator: GameItemsAllocator {

    var numberOfPlayers: Int
    var difficultyLevel: Float
    var numOfPairsPerCategory: Int

    init(numberOfPlayers: Int, difficultyLevel: Float, numOfPairsPerCategory: Int) {
        self.numberOfPlayers = numberOfPlayers
        self.difficultyLevel = difficultyLevel
        self.numOfPairsPerCategory = numOfPairsPerCategory
    }

    /// Generates items based on the given categories and allocates them to the given players
    func allocateItems(categories: [Category], players: [Player]) {
        let allItems = generateItems(categories: categories)
        let nonAssembledItems = allItems.filter { ($0 as? AssembledItem) == nil }
        allocateNonAssembledItems(items: nonAssembledItems, to: players)
        let assembledItems = allItems.compactMap { $0 as? AssembledItem }
        allocateParts(items: assembledItems, to: players)
    }

    private func allocateParts(items: [AssembledItem], to players: [Player]) {
        var parts = Array(Set(items.flatMap { $0.unsortedParts }))
        let numberOfPartsForEachPlayer = parts.count / players.count
        for player in players {
            let initialItemCount = player.items.count
            while player.items.count < numberOfPartsForEachPlayer + initialItemCount {
                guard let partToAllocate = getRandomItem(from: parts) as? Part,
                    let indexOfAllocatedPart = parts.firstIndex(of: partToAllocate) else {
                    continue
                }
                player.items.insert(partToAllocate)
                parts.remove(at: indexOfAllocatedPart)
            }
        }
    }

    private func allocateNonAssembledItems(items: [Item], to players: [Player]) {
        var itemsToAssign = items
        let numberOfItemsForEachPlayer = itemsToAssign.count / players.count
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
            allocateToRandomPlayer(players: players, item: items[0])
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

    /// Generates items based on the specified categories
    private func generateItems(categories: [Category]) -> [Item] {
        var items = [Item]()
        for category in categories {
            items.append(contentsOf: generateItems(category: category, numberToGenerate: numOfPairsPerCategory))
        }
        return items
    }

    /// Generates items for specified category
    private func generateItems(category: Category, numberToGenerate: Int) -> [Item] {
        switch category {
        case Category.book, Category.magazine, Category.bulb:
            return ListBasedGenerator.generateItems(category: category, numberToGenerate: numberToGenerate)
        case Category.toyCar:
            return AssembledItemsGenerator.generateItems(category: category, numberToGenerate: numberToGenerate)
        default:
            return [Item]()
        }
    }
}
