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
    var difficultyLevel: Float // ranges from 0 (easiest) to 1 (most difficult)

    // Refers to number of groups of items to choose per category
    // Groups are used to ensure that a minimum number of similar items are chosen
    var defaultNumOfGroups: Int = 2

    init(numberOfPlayers: Int, difficultyLevel: Float) {
        self.numberOfPlayers = numberOfPlayers
        self.difficultyLevel = difficultyLevel
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
            while player.parts.count < numberOfPartsForEachPlayer {
                guard let partToAllocate = getRandomAny(from: parts) as? Part,
                    let indexOfAllocatedPart = parts.firstIndex(of: partToAllocate) else {
                    continue
                }
                player.parts.insert(partToAllocate)
                parts.remove(at: indexOfAllocatedPart)
            }
        }
    }

    private func allocateNonAssembledItems(items: [Item], to players: [Player]) {
        var itemsToAssign = items
        let numberOfItemsForEachPlayer = itemsToAssign.count / players.count
        for player in players {
            while player.items.count < numberOfItemsForEachPlayer {
                guard let itemToAllocate = getRandomAny(from: itemsToAssign) as? Item,
                    let indexOfAllocatedItem = itemsToAssign.firstIndex(of: itemToAllocate) else {
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

    private func getRandomAny(from list: [Any]) -> Any {
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
        let numberToGenerate = numberOfPlayers * (defaultNumOfGroups + Int(difficultyLevel *
            Float(defaultNumOfGroups))) // per category
        for category in categories {
            items.append(contentsOf: generateItems(category: category, numberToGenerate: numberToGenerate))
        }
        return items
    }

    /// Generates items for specified category
    private func generateItems(category: Category, numberToGenerate: Int) -> [Item] {
        switch category {
        case Category.book, Category.magazine:
            return ListBasedGenerator.generateItems(category: category, numberToGenerate: numberToGenerate)
        case Category.toyCar:
            return AssembledItemsGenerator.generateItems(category: category, numberToGenerate: numberToGenerate)
        default:
            return [Item]()
        }
    }
}
