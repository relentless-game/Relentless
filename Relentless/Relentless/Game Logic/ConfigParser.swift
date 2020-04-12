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
    
    func getStatefulItems() {
        guard let dict = getPlist(from: plistFileName) else {
            return
        }
        
        let statefulCategories = dict.value(forKey: "statefulItems") as? [NSDictionary] ?? []
        for categoryDict in statefulCategories {
            let categoryName = categoryDict.value(forKey: "category") as? String ?? ""
            let isInventoryItem = categoryDict.value(forKey: "isInventoryItem") as? Bool ?? false
            let isOrderItem = categoryDict.value(forKey: "isOrderItem") as? Bool ?? false
            let stateImageStrings = categoryDict.value(forKey: "stateImageStrings") as? [String] ?? []
            
            convertCategoryToStatefulItems(categoryName: categoryName, isInventoryItem: isInventoryItem,
                                           isOrderItem: isOrderItem, stateImageStrings: stateImageStrings)
            //print("category name is \(categoryName), isinventitem \(isInventoryItem), isorderitem \(isOrderItem)")
        }
    }
    
    private func convertCategoryToStatefulItems(categoryName: String, isInventoryItem: Bool,
                                        isOrderItem: Bool, stateImageStrings: [String]) {
        var stateIndex = 1 // starts from one
        for string in stateImageStrings {
            // StatefulItem(category: categoryName, stateIdentifier: stateIndex,
            //              isInventoryItem: isInventoryItem, isOrderItem: isOrderItem, imageString: string)
            stateIndex += 1
        }
    }
    
    func getTitledItems() {
        guard let dict = getPlist(from: plistFileName) else {
            return
        }
        
        let titledCategories = dict.value(forKey: "titledItems") as? [NSDictionary] ?? []
        for categoryDict in titledCategories {
            let categoryName = categoryDict.value(forKey: "category") as? String ?? ""
            let isInventoryItem = categoryDict.value(forKey: "isInventoryItem") as? Bool ?? false
            let isOrderItem = categoryDict.value(forKey: "isOrderItem") as? Bool ?? false
            let titlePairs = categoryDict.value(forKey: "titles") as? [[String]] ?? []
            let imageString = categoryDict.value(forKey: "imageString") as? String ?? ""
            
            convertCategoryToTitledItems(categoryName: categoryName, isInventoryItem: isInventoryItem,
                                         isOrderItem: isOrderItem, titlePairs: titlePairs,
                                         imageString: imageString)
            //print("category name is \(categoryName), isinventitem \(isInventoryItem), isorderitem \(isOrderItem)")
        }
    }
    
    private func convertCategoryToTitledItems(categoryName: String, isInventoryItem: Bool,
                                      isOrderItem: Bool, titlePairs: [[String]], imageString: String) {
        for titlePair in titlePairs {
            let firstTitle = titlePair[0]
            let secondTitle = titlePair[1]
            
            // StatefulItem(category: categoryName, stateIdentifier: stateIndex,
            //              isInventoryItem: isInventoryItem, isOrderItem: isOrderItem, imageString: string)
        }
    }

    func getRhythmicItems() {
        guard let dict = getPlist(from: plistFileName) else {
            return
        }
        
        let rhythmicCategories = dict.value(forKey: "rhythmicItems") as? [NSDictionary] ?? []
        for categoryDict in rhythmicCategories {
            let categoryName = categoryDict.value(forKey: "category") as? String ?? ""
            let isInventoryItem = categoryDict.value(forKey: "isInventoryItem") as? Bool ?? false
            let isOrderItem = categoryDict.value(forKey: "isOrderItem") as? Bool ?? false
            let unitDurations = categoryDict.value(forKey: "unitDuration") as? [Int] ?? []
            let stateSequences = categoryDict.value(forKey: "stateSequences") as? [[String]] ?? []
            let stateImageStrings = categoryDict.value(forKey: "stateImageStrings") as? [String] ?? []
            
            convertCategoryToRhythmicItems(categoryName: categoryName, isInventoryItem: isInventoryItem,
                                           isOrderItem: isOrderItem, unitDurations: unitDurations,
                                           stateSequences: stateSequences,
                                           stateImageStrings: stateImageStrings)
            //print("category name is \(categoryName), isinventitem \(isInventoryItem), isorderitem \(isOrderItem)")
        }
    }
    
    private func convertCategoryToRhythmicItems(categoryName: String, isInventoryItem: Bool,
                                                isOrderItem: Bool, unitDurations: [Int],
                                                stateSequences: [[String]],
                                                stateImageStrings: [String]) {
        for duration in unitDurations {
            
            // StatefulItem(category: categoryName, stateIdentifier: stateIndex,
            //              isInventoryItem: isInventoryItem, isOrderItem: isOrderItem, imageString: string)
        }
    }
    
    func getAssembledItems() {
        guard let dict = getPlist(from: plistFileName) else {
            return
        }
        
        let assembledCategories = dict.value(forKey: "assembledItems") as? [NSDictionary] ?? []
        for categoryDict in assembledCategories {
            let categoryName = categoryDict.value(forKey: "category") as? String ?? ""
            let isInventoryItem = categoryDict.value(forKey: "isInventoryItem") as? Bool ?? false
            let isOrderItem = categoryDict.value(forKey: "isOrderItem") as? Bool ?? false
            let parts = categoryDict.value(forKey: "parts") as? [String] ?? []
            
            convertCategoryToAssembledItems(categoryName: categoryName, isInventoryItem: isInventoryItem,
                                            isOrderItem: isOrderItem, parts: parts)
            //print("category name is \(categoryName), isinventitem \(isInventoryItem), isorderitem \(isOrderItem)")
        }
    }
    
    private func convertCategoryToAssembledItems(categoryName: String, isInventoryItem: Bool,
                                                 isOrderItem: Bool, parts: [String]) {

        // do the permutations thing?
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
