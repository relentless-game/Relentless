//
//  ConfigParser.swift
//  Relentless
//
//  Created by Liu Zechu on 12/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class ConfigParser {
    let plistFileName = "GameConfig"
    
    func parse() -> ItemSpecifications {
        
        // 1. get available items
        let availableStatefulItems = getStatefulItems()
        let availableTitledItems = getTitledItems()
        let availableRhythmicItems = getRhythmicItems()
        
        var availableItems: [Category: Set<[Item]>] = [:]
        availableItems.merge(availableStatefulItems) { current, _ in current } // keeps current during merging
        availableItems.merge(availableTitledItems) { current, _ in current }
        availableItems.merge(availableRhythmicItems) { current, _ in current }
        
        let availableAssembledItems = getAssembledItems(availableAtomicItems: availableItems)
        availableItems.merge(availableAssembledItems) { current, _ in current }

        // 2. get stateful items identifier mappings
        let itemIdentifierMappings = getStateIdentifierMappings()
        
        // 3. get partsToAssembledItemCategoryMapping
        let partsToAssembledItemCategoryMapping = getPartsToAssembledItemCategoryMapping()
    
        return ItemSpecifications(availableGroupsOfItems: availableItems,
                                  itemIdentifierMappings: itemIdentifierMappings,
                                  partsToAssembledItemCategoryMapping: partsToAssembledItemCategoryMapping)
    }
    
    func getStateIdentifierMappings() -> [Category: [Int: String]] {
        guard let dict = getPlist(from: plistFileName) else {
            return [:]
        }
        
        let statefulCategories = dict.value(forKey: "statefulItems") as? [NSDictionary] ?? []
        var allMappings: [Category: [Int: String]] = [:]
        for categoryDict in statefulCategories {
            let categoryName = categoryDict.value(forKey: "category") as? String ?? ""
            let category = Category(name: categoryName)
            let stateIdentifiers = categoryDict.value(forKey: "stateIdentifiers") as? [String] ?? []
            
            // convert into a [Int: String] dictionary
            var mapping: [Int: String] = [:]
            var index = 1 // start from 1
            for identifier in stateIdentifiers {
                mapping[index] = identifier
                index += 1
            }
            allMappings[category] = mapping
        }
        
        return allMappings
    }
    
    func getStatefulItems() -> [Category: Set<[StatefulItem]>] {
        guard let dict = getPlist(from: plistFileName) else {
            return [:]
        }
        
        let statefulCategories = dict.value(forKey: "statefulItems") as? [NSDictionary] ?? []
        var allStatefulItems: [Category: Set<[StatefulItem]>] = [:]
        for categoryDict in statefulCategories {
            let categoryName = categoryDict.value(forKey: "category") as? String ?? ""
            let isInventoryItem = categoryDict.value(forKey: "isInventoryItem") as? Bool ?? false
            let isOrderItem = categoryDict.value(forKey: "isOrderItem") as? Bool ?? false
            let stateImageStrings = categoryDict.value(forKey: "stateImageStrings") as? [String] ?? []
            
            let items = convertCategoryToStatefulItems(categoryName: categoryName, isInventoryItem: isInventoryItem,
                                                       isOrderItem: isOrderItem, stateImageStrings: stateImageStrings)
            let category = Category(name: categoryName)
            allStatefulItems[category] = items
        }
        
        return allStatefulItems
    }
    
    private func convertCategoryToStatefulItems(categoryName: String, isInventoryItem: Bool,
                                                isOrderItem: Bool,
                                                stateImageStrings: [String]) -> Set<[StatefulItem]> {
        var stateIndex = 1 // starts from one
        var statefulItems = Set<[StatefulItem]>()
        for string in stateImageStrings {
            let category = Category(name: categoryName)
            let item = StatefulItem(category: category, stateIdentifier: stateIndex,
                                    isInventoryItem: isInventoryItem, isOrderItem: isOrderItem,
                                    imageString: string)
            statefulItems.insert([item])
            stateIndex += 1
        }
        
        return statefulItems
    }
    
    func getTitledItems() -> [Category: Set<[TitledItem]>] {
        guard let dict = getPlist(from: plistFileName) else {
            return [:]
        }
        
        let titledCategories = dict.value(forKey: "titledItems") as? [NSDictionary] ?? []
        var allTitledItems: [Category: Set<[TitledItem]>] = [:]
        for categoryDict in titledCategories {
            let categoryName = categoryDict.value(forKey: "category") as? String ?? ""
            let isInventoryItem = categoryDict.value(forKey: "isInventoryItem") as? Bool ?? false
            let isOrderItem = categoryDict.value(forKey: "isOrderItem") as? Bool ?? false
            let titlePairs = categoryDict.value(forKey: "titles") as? [[String]] ?? []
            let imageString = categoryDict.value(forKey: "imageString") as? String ?? ""
            
            let items = convertCategoryToTitledItems(categoryName: categoryName, isInventoryItem: isInventoryItem,
                                                     isOrderItem: isOrderItem, titleGroups: titlePairs,
                                                     imageString: imageString)
            let category = Category(name: categoryName)
            allTitledItems[category] = items
        }
        
        return allTitledItems
    }
    
    private func convertCategoryToTitledItems(categoryName: String, isInventoryItem: Bool,
                                              isOrderItem: Bool, titleGroups: [[String]],
                                              imageString: String) -> Set<[TitledItem]> {
        var result = Set<[TitledItem]>()
        let category = Category(name: categoryName)
        for titleGroup in titleGroups {
            var itemGroup: [TitledItem] = []
            for title in titleGroup {
                let item = TitledItem(name: title, category: category,
                                      isInventoryItem: isInventoryItem, isOrderItem: isOrderItem,
                                      imageString: imageString)
                itemGroup.append(item)
            }
            
            result.insert(itemGroup)
        }
        
        return result
    }

    func getRhythmicItems() -> [Category: Set<[RhythmicItem]>] {
        guard let dict = getPlist(from: plistFileName) else {
            return [:]
        }
        
        let rhythmicCategories = dict.value(forKey: "rhythmicItems") as? [NSDictionary] ?? []
        var allRhythmicItems: [Category: Set<[RhythmicItem]>] = [:]
        for categoryDict in rhythmicCategories {
            let categoryName = categoryDict.value(forKey: "category") as? String ?? ""
            let isInventoryItem = categoryDict.value(forKey: "isInventoryItem") as? Bool ?? false
            let isOrderItem = categoryDict.value(forKey: "isOrderItem") as? Bool ?? false
            let itemGroups = categoryDict.value(forKey: "itemGroups") as? [[NSDictionary]] ?? []
            // TODO: clarify how to specify image assets for rhythmic items
            let imageString = categoryDict.value(forKey: "imageString") as? String ?? ""
            
            let items = convertCategoryToRhythmicItems(categoryName: categoryName, isInventoryItem: isInventoryItem,
                                                       isOrderItem: isOrderItem,
                                                       itemGroups: itemGroups,
                                                       imageString: imageString)
            let category = Category(name: categoryName)
            allRhythmicItems[category] = items
        }
        
        return allRhythmicItems
    }
    
    private func convertCategoryToRhythmicItems(categoryName: String, isInventoryItem: Bool,
                                                isOrderItem: Bool,
                                                itemGroups: [[NSDictionary]],
                                                imageString: String) -> Set<[RhythmicItem]> {
        let category = Category(name: categoryName)
        var result = Set<[RhythmicItem]>()
        for itemGroup in itemGroups {
            var itemGroupArray: [RhythmicItem] = []
            for rawItemDict in itemGroup {
                let unitDuration = rawItemDict.value(forKey: "unitDuration") as? Int ?? 0
                let rawStateSequence = rawItemDict.value(forKey: "stateSequence") as? [Int] ?? []
                let stateSequence = convertIntArrayToRhythmStateArray(intArray: rawStateSequence)
                
                let item = RhythmicItem(unitDuration: unitDuration, stateSequence: stateSequence,
                                        category: category, isInventoryItem: isInventoryItem,
                                        isOrderItem: isOrderItem, imageString: imageString)
                itemGroupArray.append(item)
            }
            result.insert(itemGroupArray)
        }
        
        return result
    }
    
    private func convertIntArrayToRhythmStateArray(intArray: [Int]) -> [RhythmState] {
        var result: [RhythmState] = []
        for integer in intArray {
            if integer == 0 {
                result.append(.unlit)
            } else if integer == 1 {
                result.append(.lit)
            }
        }
        return result
    }
    
    // TODO: for now, only can assemble depth 0 items
    func getAssembledItems(availableAtomicItems: [Category: Set<[Item]>]) -> [Category: Set<[AssembledItem]>] {
        guard let dict = getPlist(from: plistFileName) else {
            return [:]
        }
        
        let assembledCategories = dict.value(forKey: "assembledItems") as? [NSDictionary] ?? []
        var allAssembledItems: [Category: Set<[AssembledItem]>] = [:]
        for categoryDict in assembledCategories {
            let categoryName = categoryDict.value(forKey: "category") as? String ?? ""
            let isInventoryItem = categoryDict.value(forKey: "isInventoryItem") as? Bool ?? false
            let isOrderItem = categoryDict.value(forKey: "isOrderItem") as? Bool ?? false
            let parts = categoryDict.value(forKey: "parts") as? [String] ?? []
            // TODO: use depth
            let depth = categoryDict.value(forKey: "depth") as? Int ?? 0
            
            let items = convertCategoryToAssembledItems(categoryName: categoryName, isInventoryItem: isInventoryItem,
                                                        isOrderItem: isOrderItem, parts: parts,
                                                        availableAtomicItems: availableAtomicItems)
            let category = Category(name: categoryName)
            allAssembledItems[category] = items
        }
        
        return allAssembledItems
    }
    
    // TODO: how to represent image strings for assembled items?
    func convertCategoryToAssembledItems(categoryName: String, isInventoryItem: Bool,
                                         isOrderItem: Bool, parts: [String],
                                         availableAtomicItems: [Category: Set<[Item]>]) -> Set<[AssembledItem]> {
//        let availableParts = Array(availableAtomicItems.values).map { set in
//            Array(set).flatMap { $0 }
//        }
        
        var availableParts: [[Item]] = []
        for part in parts {
            let partCategory = Category(name: part)
            let partItemsSet = availableAtomicItems[partCategory] ?? []
            let partItemsArray = Array(partItemsSet).flatMap { $0 }
            availableParts.append(partItemsArray)
        }
        
        var allAssembledItems = Set<[AssembledItem]>()
        let category = Category(name: categoryName)
        let allPermutations = permuteParts(availableParts: availableParts, currentIndex: 0)
        for permutation in allPermutations {
            let item = AssembledItem(parts: permutation, category: category,
                                     isInventoryItem: isInventoryItem, isOrderItem: isOrderItem,
                                     imageString: "placeholder")
            allAssembledItems.insert([item])
        }
        
        return allAssembledItems
    }
    
    // Recursively selects item from each part, and returns an array of all permutations, each
    // permutation being an array of part items.
    func permuteParts(availableParts: [[Item]], currentIndex: Int) -> [[Item]] {
        guard currentIndex < availableParts.count else {
            return [[]]
        }
        
        let currentItems = availableParts[currentIndex]
        let partialResults = permuteParts(availableParts: availableParts,
                                          currentIndex: currentIndex + 1)
        var result: [[Item]] = []
        for item in currentItems {
            for partialResult in partialResults {
                var newArray = [item]
                newArray.append(contentsOf: partialResult)
                result.append(newArray)
            }
        }
        
        return result
    }
    
    private func getPartsToAssembledItemCategoryMapping() -> [[Category]: Category] {
        guard let dict = getPlist(from: plistFileName) else {
            return [:]
        }
        
        let assembledCategories = dict.value(forKey: "assembledItems") as? [NSDictionary] ?? []
        var mappings: [[Category]: Category] = [:]
        for categoryDict in assembledCategories {
            let categoryName = categoryDict.value(forKey: "category") as? String ?? ""
            let category = Category(name: categoryName)
            
            let parts = categoryDict.value(forKey: "parts") as? [String] ?? []
            let CategoriesForParts = parts.map { Category(name: $0) }
            
            mappings[CategoriesForParts] = category
        }
        
        return mappings
    }
    
    func getPlist(from fileName: String) -> NSDictionary? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path) {
            let contents = (try? PropertyListSerialization.propertyList(from: xml,
                                                                        options: .mutableContainersAndLeaves,
                                                                        format: nil)) as? NSDictionary
            
            return contents
        }

        return nil
    }
}
