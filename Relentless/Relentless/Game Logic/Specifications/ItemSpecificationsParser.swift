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
    
    // String key constants
    static let statefulItemsKey = "statefulItems"
    static let titledItemsKey = "titledItems"
    static let rhythmicItemsKey = "rhythmicItems"
    static let assembledItemsKey = "assembledItems"
    static let categoryKey = "category"
    static let isInventoryItemKey = "isInventoryItem"
    static let isOrderItemKey = "isOrderItem"
    static let stateIdentifiersKey = "stateIdentifiers"
    static let stateImageStringsKey = "stateImageStrings"
    static let titlesKey = "titles"
    static let imageStringKey = "imageString"
    static let itemGroupsKey = "itemGroups"
    static let unitDurationKey = "unitDuration"
    static let stateSequenceKey = "stateSequence"
    static let partsKey = "parts"
    static let depthKey = "depth"
    static let mainImageStringKey = "mainImageString"
    static let partsImageStringsKey = "partsImageStrings"
    
    static func parse() -> ItemSpecifications {
        let itemsDict: NSDictionary!
        do {
            itemsDict = try getPlist(from: plistFileName)
        } catch {
            itemsDict = [:]
            assertionFailure("Loading Plist failed.")
        }
        
        // 1. get available items
        let availableStatefulItems = getStatefulItems(dict: itemsDict)
        let availableTitledItems = getTitledItems(dict: itemsDict)
        let availableRhythmicItems = getRhythmicItems(dict: itemsDict)
        
        var availableItems: [Category: Set<[Item]>] = [:]
        availableItems.merge(availableStatefulItems) { current, _ in current } // keeps current during merging
        availableItems.merge(availableTitledItems) { current, _ in current }
        availableItems.merge(availableRhythmicItems) { current, _ in current }
        
        let availableAssembledItems = getAssembledItems(dict: itemsDict, availableAtomicItems: availableItems)
        availableItems.merge(availableAssembledItems) { current, _ in current }

        // 2. get stateful items identifier mappings
        let itemIdentifierMappings = getStateIdentifierMappings(dict: itemsDict)
        
        // 3. get partsToAssembledItemCategoryMapping
        let partsToAssembledItemCategoryMapping = getPartsToAssembledItemCategoryMapping(dict: itemsDict)
    
        return ItemSpecifications(availableGroupsOfItems: availableItems,
                                  itemIdentifierMappings: itemIdentifierMappings,
                                  partsToAssembledItemCategoryMapping: partsToAssembledItemCategoryMapping)
    }
    
    static func getStateIdentifierMappings(dict: NSDictionary) -> [Category: [Int: String]] {
        let statefulCategories = dict.value(forKey: statefulItemsKey) as? [NSDictionary] ?? []
        var allMappings: [Category: [Int: String]] = [:]
        for categoryDict in statefulCategories {
            let categoryName = categoryDict.value(forKey: categoryKey) as? String ?? ""
            let category = Category(name: categoryName)
            let stateIdentifiers = categoryDict.value(forKey: stateIdentifiersKey) as? [String] ?? []
            
            // convert into a [Int: String] dictionary
            var mapping: [Int: String] = [:]
            var index = 0
            for identifier in stateIdentifiers {
                mapping[index] = identifier
                index += 1
            }
            allMappings[category] = mapping
        }
        
        return allMappings
    }
    
    static func getStatefulItems(dict: NSDictionary) -> [Category: Set<[StatefulItem]>] {
        let statefulCategories = dict.value(forKey: statefulItemsKey) as? [NSDictionary] ?? []
        var allStatefulItems: [Category: Set<[StatefulItem]>] = [:]
        for categoryDict in statefulCategories {
            let categoryName = categoryDict.value(forKey: categoryKey) as? String ?? ""
            let isInventoryItem = categoryDict.value(forKey: isInventoryItemKey) as? Bool ?? false
            let isOrderItem = categoryDict.value(forKey: isOrderItemKey) as? Bool ?? false
            let stateImageStrings = categoryDict.value(forKey: stateImageStringsKey) as? [String] ?? []
            
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
        var stateIndex = 0
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
    
    static func getTitledItems(dict: NSDictionary) -> [Category: Set<[TitledItem]>] {
        let titledCategories = dict.value(forKey: titledItemsKey) as? [NSDictionary] ?? []
        var allTitledItems: [Category: Set<[TitledItem]>] = [:]
        for categoryDict in titledCategories {
            let categoryName = categoryDict.value(forKey: categoryKey) as? String ?? ""
            let isInventoryItem = categoryDict.value(forKey: isInventoryItemKey) as? Bool ?? false
            let isOrderItem = categoryDict.value(forKey: isOrderItemKey) as? Bool ?? false
            let titlePairs = categoryDict.value(forKey: titlesKey) as? [[String]] ?? []
            let imageString = categoryDict.value(forKey: imageStringKey) as? String ?? ""
            
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

    static func getRhythmicItems(dict: NSDictionary) -> [Category: Set<[RhythmicItem]>] {
        let rhythmicCategories = dict.value(forKey: rhythmicItemsKey) as? [NSDictionary] ?? []
        var allRhythmicItems: [Category: Set<[RhythmicItem]>] = [:]
        for categoryDict in rhythmicCategories {
            let categoryName = categoryDict.value(forKey: categoryKey) as? String ?? ""
            let isInventoryItem = categoryDict.value(forKey: isInventoryItemKey) as? Bool ?? false
            let isOrderItem = categoryDict.value(forKey: isOrderItemKey) as? Bool ?? false
            let itemGroups = categoryDict.value(forKey: itemGroupsKey) as? [[NSDictionary]] ?? []
            let stateImageStrings = categoryDict.value(forKey: stateImageStringsKey) as? [String] ?? []
            
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
                let unitDuration = rawItemDict.value(forKey: unitDurationKey) as? Int ?? 0
                let rawStateSequence = rawItemDict.value(forKey: stateSequenceKey) as? [Int] ?? []
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
            result.append(RhythmState(index: integer))
        }
        return result
    }
    
    static func getAssembledItems(dict: NSDictionary,
                                  availableAtomicItems: [Category: Set<[Item]>]) -> [Category: Set<[AssembledItem]>] {
        let assembledCategories = dict.value(forKey: assembledItemsKey) as? [NSDictionary] ?? []
        var intermediateItems: [IntermediateAssembledItem] = []
        for categoryDict in assembledCategories {
            let categoryName = categoryDict.value(forKey: categoryKey) as? String ?? ""
            let category = Category(name: categoryName)
            let isInventoryItem = categoryDict.value(forKey: isInventoryItemKey) as? Bool ?? false
            let isOrderItem = categoryDict.value(forKey: isOrderItemKey) as? Bool ?? false
            let parts = categoryDict.value(forKey: partsKey) as? [String] ?? []
            let depth = categoryDict.value(forKey: depthKey) as? Int ?? -1
            let mainImageString = categoryDict.value(forKey: mainImageStringKey) as? String ?? ""
            let rawPartsImageStrings = categoryDict.value(forKey: partsImageStringsKey) as? [String: [String]] ?? [:]
            var partsImageStrings: [Category: [String]] = [:]
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
        
        var availableItems = availableAtomicItems
        var allAssembledItems: [Category: Set<[AssembledItem]>] = [:]
        
        // Assemble items according to increasing depths
        intermediateItems.sort { $0.depth < $1.depth }
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
                                                        partsImageStrings: [Category: [String]]) -> Set<[AssembledItem]> {
        
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
    
    private static func getPartsToAssembledItemCategoryMapping(dict: NSDictionary) -> [[Category]: Category] {
        let assembledCategories = dict.value(forKey: assembledItemsKey) as? [NSDictionary] ?? []
        var mappings: [[Category]: Category] = [:]
        for categoryDict in assembledCategories {
            let categoryName = categoryDict.value(forKey: categoryKey) as? String ?? ""
            let category = Category(name: categoryName)
            
            let parts = categoryDict.value(forKey: partsKey) as? [String] ?? []
            let CategoriesForParts = parts.map { Category(name: $0) }
            
            mappings[CategoriesForParts] = category
        }
        
        return mappings
    }
    
    static func getPlist(from fileName: String) throws -> NSDictionary {
        if let path = Bundle.main.path(forResource: fileName, ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path) {
            if let contents = (try? PropertyListSerialization.propertyList(from: xml,
                                                                           options: .mutableContainersAndLeaves,
                                                                           format: nil)) as? NSDictionary {
                return contents
            } else {
                throw ItemSpecsParserError.plistLoadingError
            }
        }
        throw ItemSpecsParserError.plistLoadingError
    }
}

// temporary structure to hold information for an assembled item
struct IntermediateAssembledItem {
    let category: Category
    let isInventoryItem: Bool
    let isOrderItem: Bool
    let parts: [String]
    let depth: Int
    let mainImageString: String
    let partsImageStrings: [Category: [String]]
    
    init(category: Category, isInventoryItem: Bool, isOrderItem: Bool,
         parts: [String], depth: Int, mainImageString: String, partsImageStrings: [Category: [String]]) {
        self.category = category
        self.isInventoryItem = isInventoryItem
        self.isOrderItem = isOrderItem
        self.parts = parts
        self.depth = depth
        self.mainImageString = mainImageString
        self.partsImageStrings = partsImageStrings
    }
}

enum ItemSpecsParserError: Error {
    case plistLoadingError
}
