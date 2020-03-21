//
//  ListBasedGenerator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 15/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// Generates items through choosing from pre-defined lists
class ListBasedGenerator: ItemGenerator {

    static func generateItems(category: Category, numberToGenerate: Int) -> [Item] {
        let list = getList(category: category)
        let selectedItems = selectItems(list: list, numberOfGroups: numberToGenerate)
        return selectedItems
    }

    private static func getList(category: Category) -> [[Item]] {
        switch category {
        case Category.book:
            return ItemsLists.books
        case Category.magazine:
            return ItemsLists.magazines
        }
    }

    private static func selectItems(list: [[Item]], numberOfGroups: Int) -> [Item] {
        var groups = Set<[Item]>()
        // if number of groups in list is less than required, just return all available groups
        if list.count < numberOfGroups {
            groups = Set(list)
        } else {
            let maxNumber = list.count - 1
            let range = 0...maxNumber
            while groups.count < numberOfGroups {
                let randomNumber = Int.random(in: range)
                groups.insert(list[randomNumber])
            }
        }
        var items = [Item]()
        for group in groups {
            items.append(contentsOf: group)
        }
        return items
    }

}
