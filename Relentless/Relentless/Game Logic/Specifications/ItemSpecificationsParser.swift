//
//  ItemSpecificationsParser.swift
//  Relentless
//
//  Created by Chow Yi Yin on 12/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class ItemSpecificationsParser {
    static let plistFileName = "GameConfig"
    
    static func parse() -> ItemSpecifications {
        
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
    
    static func getStateIdentifierMappings() -> [Category: [Int: String]] {
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
    
    static func getStatefulItems() -> [Category: Set<[StatefulItem]>] {
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
    
    private static func convertCategoryToStatefulItems(categoryName: String, isInventoryItem: Bool,
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
    
    static func getTitledItems() -> [Category: Set<[TitledItem]>] {
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
    
    private static func convertCategoryToTitledItems(categoryName: String, isInventoryItem: Bool,
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

    static func getRhythmicItems() -> [Category: Set<[RhythmicItem]>] {
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
            let stateImageStrings = categoryDict.value(forKey: "stateImageStrings") as? [String] ?? []
            
            let items = convertCategoryToRhythmicItems(categoryName: categoryName, isInventoryItem: isInventoryItem,
                                                       isOrderItem: isOrderItem,
                                                       itemGroups: itemGroups,
                                                       stateImageStrings: stateImageStrings)
            let category = Category(name: categoryName)
            allRhythmicItems[category] = items
        }
        
        return allRhythmicItems
    }
    
    private static func convertCategoryToRhythmicItems(categoryName: String, isInventoryItem: Bool,
                                                       isOrderItem: Bool,
                                                       itemGroups: [[NSDictionary]],
                                                       stateImageStrings: [String]) -> Set<[RhythmicItem]> {
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
                                        isOrderItem: isOrderItem, imageStrings: stateImageStrings)
                itemGroupArray.append(item)
            }
            result.insert(itemGroupArray)
        }
        
        return result
    }
    
    private static func convertIntArrayToRhythmStateArray(intArray: [Int]) -> [RhythmState] {
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
    
    static func getAssembledItems(availableAtomicItems: [Category: Set<[Item]>]) -> [Category: Set<[AssembledItem]>] {
        guard let dict = getPlist(from: plistFileName) else {
            return [:]
        }
        
        let assembledCategories = dict.value(forKey: "assembledItems") as? [NSDictionary] ?? []
        var intermediateItems: [IntermediateAssembledItem] = []
        for categoryDict in assembledCategories {
            let categoryName = categoryDict.value(forKey: "category") as? String ?? ""
            let category = Category(name: categoryName)
            let isInventoryItem = categoryDict.value(forKey: "isInventoryItem") as? Bool ?? false
            let isOrderItem = categoryDict.value(forKey: "isOrderItem") as? Bool ?? false
            let parts = categoryDict.value(forKey: "parts") as? [String] ?? []
            let depth = categoryDict.value(forKey: "depth") as? Int ?? -1
            let mainImageString = categoryDict.value(forKey: "mainImageString") as? String ?? ""
            let rawPartsImageStrings = categoryDict.value(forKey: "partsImageStrings") as? [String: String] ?? [:]
            var partsImageStrings: [Category: String] = [:]
            for (key, value) in rawPartsImageStrings {
                partsImageStrings[Category(name: key)] = value
            }
            
            let intermediateAssembledItem = IntermediateAssembledItem(category: category,
                                                                      isInventoryItem: isInventoryItem,
                                                                      isOrderItem: isOrderItem,
                                                                      parts: parts,
                                                                      depth: depth,
                                                                      mainImageString: mainImageString,
                                                                      partsImageStrings: partsImageStrings)
            intermediateItems.append(intermediateAssembledItem)
        }
        intermediateItems.sort { $0.depth < $1.depth }
        
        var availableItems = availableAtomicItems
        var allAssembledItems: [Category: Set<[AssembledItem]>] = [:]
        
        // Assemble items according to increasing depths
        for intermediateItem in intermediateItems {
            let category = intermediateItem.category
            let isInventoryItem = intermediateItem.isInventoryItem
            let isOrderItem = intermediateItem.isOrderItem
            let parts = intermediateItem.parts
            let mainImageString = intermediateItem.mainImageString
            let partsImageStrings = intermediateItem.partsImageStrings
            
            let items = convertCategoryToAssembledItems(category: category, isInventoryItem: isInventoryItem,
                                                        isOrderItem: isOrderItem, parts: parts,
                                                        availableAtomicItems: availableItems,
                                                        mainImageString: mainImageString,
                                                        partsImageStrings: partsImageStrings)
            allAssembledItems[category] = items
            availableItems[category] = items
        }
        
        return allAssembledItems
    }
    
    private static func convertCategoryToAssembledItems(category: Category, isInventoryItem: Bool,
                                                        isOrderItem: Bool, parts: [String],
                                                        availableAtomicItems: [Category: Set<[Item]>],
                                                        mainImageString: String,
                                                        partsImageStrings: [Category: String]) -> Set<[AssembledItem]> {
        
        var availableParts: [[Item]] = []
        for part in parts {
            let partCategory = Category(name: part)
            let partItemsSet = availableAtomicItems[partCategory] ?? []
            let partItemsArray = Array(partItemsSet).flatMap { $0 }
            availableParts.append(partItemsArray)
        }
        
        var allAssembledItems = Set<[AssembledItem]>()
        let allPermutations = permuteParts(availableParts: availableParts, currentIndex: 0)
        for permutation in allPermutations {
            let item = AssembledItem(parts: permutation, category: category,
                                     isInventoryItem: isInventoryItem, isOrderItem: isOrderItem,
                                     mainImageString: mainImageString, partsImageStrings: partsImageStrings)
            allAssembledItems.insert([item])
        }
        
        return allAssembledItems
    }
    
    // Recursively selects item from each part, and returns an array of all permutations, each
    // permutation being an array of part items.
    static func permuteParts(availableParts: [[Item]], currentIndex: Int) -> [[Item]] {
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
    
    private static func getPartsToAssembledItemCategoryMapping() -> [[Category]: Category] {
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
    
    static func getPlist(from fileName: String) -> NSDictionary? {
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

struct IntermediateAssembledItem {
    let category: Category
    let isInventoryItem: Bool
    let isOrderItem: Bool
    let parts: [String]
    let depth: Int
    let mainImageString: String
    let partsImageStrings: [Category: String]
    
    init(category: Category, isInventoryItem: Bool, isOrderItem: Bool,
         parts: [String], depth: Int, mainImageString: String, partsImageStrings: [Category: String]) {
        self.category = category
        self.isInventoryItem = isInventoryItem
        self.isOrderItem = isOrderItem
        self.parts = parts
        self.depth = depth
        self.mainImageString = mainImageString
        self.partsImageStrings = partsImageStrings
    }
}
