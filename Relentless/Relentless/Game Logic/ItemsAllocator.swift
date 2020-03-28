//
//  ItemsAllocator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class ItemsAllocator: GameItemsAllocator {

    var generatedItemsByCategory: [Category: [Item]] = [:]

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
        generateItems(categories: categories)
        var items = consolidateAllItems()
        let numberOfItemsForEachPlayer = items.count / players.count
        for player in players {
            while player.items.count < numberOfItemsForEachPlayer {
                let indexOfAllocatedItem = allocateRandomItem(to: player, items: items)
                items.remove(at: indexOfAllocatedItem)
            }
        }
        // randomly assign remaining items
        while !items.isEmpty {
            allocateToRandomPlayer(players: players, item: items[0])
            items.remove(at: 0)
        }
    }

    /// Chooses a random item from all items and assigns it to the player
    private func allocateRandomItem(to player: Player, items: [Item]) -> Int {
        let indexRange = 0...(items.count - 1)
        let randomIndex = Int.random(in: indexRange)
        let randomItem = items[randomIndex]
        player.items.insert(randomItem)
        return randomIndex
    }

    /// Chooses a random player and allocates the item to that player
    private func allocateToRandomPlayer(players: [Player], item: Item) {
        let playerIndexRange = 0...(players.count - 1)
        let randomPlayer = players[Int.random(in: playerIndexRange)]
        randomPlayer.items.insert(item)
    }

    /// Generates items based on the specified categories
    private func generateItems(categories: [Category]) {
        var items = [Category: [Item]]()
        for category in categories {
            items[category] = generateItems(category: category, numberToGenerate: numOfPairsPerCategory)
        }
        generatedItemsByCategory = items
    }

    /// Generates items for specified category
    private func generateItems(category: Category, numberToGenerate: Int) -> [Item] {
        switch category {
        case Category.book, Category.magazine, Category.bulb:
            return ListBasedGenerator.generateItems(category: category, numberToGenerate: numberToGenerate)
        }
    }

    /// Consolidates all generated items into a single array
    private func consolidateAllItems() -> [Item] {
        var items = [Item]()
        for category in generatedItemsByCategory.keys {
            guard let categoryItems = generatedItemsByCategory[category] else {
                continue
            }
            items.append(contentsOf: categoryItems)
        }
        return items
    }
}
