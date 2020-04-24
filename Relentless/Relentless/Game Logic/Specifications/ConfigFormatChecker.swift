//
//  ConfigFormatChecker.swift
//  Relentless
//
//  Created by Liu Zechu on 24/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

typealias Parser = ItemSpecificationsParser

class ConfigFormatChecker {
    
    static let statefulItemsErrorMessage = "statefulItems should be an array of dictionaries"
    static let titledItemsErrorMessage = "titledItems should be an array of dictionaries"
    static let rhythmicItemsErrorMessage = "rhythmicItems should be an array of dictionaries"
    static let assembledItemsErrorMessage = "assembledItems should be an array of dictionaries"
    
    static func check(configDict: NSDictionary) throws {
        guard let statefulItems = configDict.value(forKey: Parser.statefulItemsKey) as? [NSDictionary] else {
            throw GameConfigError.formatError(message: statefulItemsErrorMessage)
        }
        guard let titledItems = configDict.value(forKey: Parser.titledItemsKey) as? [NSDictionary] else {
            throw GameConfigError.formatError(message: titledItemsErrorMessage)
        }
        guard let rhythmicItems = configDict.value(forKey: Parser.rhythmicItemsKey) as? [NSDictionary] else {
            throw GameConfigError.formatError(message: rhythmicItemsErrorMessage)
        }
        guard let assembledItems = configDict.value(forKey: Parser.assembledItemsKey) as? [NSDictionary] else {
            throw GameConfigError.formatError(message: assembledItemsErrorMessage)
        }
           
        try checkStatefulItems(items: statefulItems)
        try checkTitledItems(items: titledItems)
        try checkRhythmicItems(items: rhythmicItems)
        try checkAssembledItems(items: assembledItems)
        
    }
    
    private static func checkStatefulItems(items: [NSDictionary]) throws {
        let errorMessage = "%@ under statefulItems cannot be cast to %@."
        for rawCategory in items {
            try checkStandardKeys(dict: rawCategory, type: "statefulItems")
            
            guard let imageStrings = rawCategory.value(forKey: Parser.stateImageStringsKey) as? [String] else {
                let message = String(format: errorMessage, arguments: [Parser.stateImageStringsKey, "[String]"])
                throw GameConfigError.formatError(message: message)
            }
            guard let stateIdentifiers = rawCategory.value(forKey: Parser.stateIdentifiersKey) as? [String] else {
                let message = String(format: errorMessage, arguments: [Parser.stateIdentifiersKey, "[String]"])
                throw GameConfigError.formatError(message: message)
            }
            
            if imageStrings.count != stateIdentifiers.count {
                let message = "\(Parser.stateImageStringsKey) and " +
                    "\(Parser.stateIdentifiersKey) should have the same length."
                throw GameConfigError.formatError(message: message)
            }
        }
    }
    
    private static func checkTitledItems(items: [NSDictionary]) throws {
        let errorMessage = "%@ under titledItems cannot be cast to %@."
        for rawCategory in items {
            try checkStandardKeys(dict: rawCategory, type: "titledItems")
            
            if rawCategory.value(forKey: Parser.titlesKey) as? [[String]] == nil {
                let message = String(format: errorMessage, arguments: [Parser.titlesKey, "[[String]]"])
                throw GameConfigError.formatError(message: message)
            }
            if rawCategory.value(forKey: Parser.imageStringKey) as? String == nil {
                let message = String(format: errorMessage, arguments: [Parser.imageStringKey, "String"])
                throw GameConfigError.formatError(message: message)
            }
        }
    }
    
    private static func checkRhythmicItems(items: [NSDictionary]) throws {
        let errorMessage = "%@ under rhythmicItems cannot be cast to %@."
        for rawCategory in items {
            try checkStandardKeys(dict: rawCategory, type: "rhythmicItems")
            
            guard let itemGroups = rawCategory.value(forKey: Parser.itemGroupsKey) as? [[NSDictionary]] else {
                let message = String(format: errorMessage, arguments: [Parser.itemGroupsKey, "[[NSDictionary]]"])
                throw GameConfigError.formatError(message: message)
            }
            var stateIndices = Set<Int>()
            for group in itemGroups {
                for rhythmicItem in group {
                    if rhythmicItem.value(forKey: Parser.unitDurationKey) as? String == nil {
                        let message = String(format: errorMessage, arguments: [Parser.unitDurationKey, "String"])
                        throw GameConfigError.formatError(message: message)
                    }
                    if let stateSequence = rhythmicItem.value(forKey: Parser.stateSequenceKey) as? [Int] {
                        for stateIndex in stateSequence {
                            stateIndices.insert(stateIndex)
                        }
                    } else {
                        let message = String(format: errorMessage, arguments: [Parser.stateSequenceKey, "[Int]"])
                        throw GameConfigError.formatError(message: message)
                    }
                }
            }
            // check whether the state indices entered are valid
            let maxStateIndex = stateIndices.max()
            let minStateIndex = stateIndices.min()
            if maxStateIndex != stateIndices.count - 1 || minStateIndex != 0 {
                let message = "State indices in stateSequence array should start from 0."
                throw GameConfigError.formatError(message: message)
            }
           
            guard let imageStrings = rawCategory.value(forKey: Parser.stateImageStringsKey) as? [String] else {
                let message = String(format: errorMessage, arguments: [Parser.stateImageStringsKey, "[String]"])
                throw GameConfigError.formatError(message: message)
            }
            if imageStrings.count != (maxStateIndex ?? -2) + 1 {
                let message = "Each rhythm state should have a corresponding image."
                throw GameConfigError.formatError(message: message)
            }
        }
    }
    
    private static func checkAssembledItems(items: [NSDictionary]) throws {
        let errorMessage = "%@ under assembledItems cannot be cast to %@."
        for rawCategory in items {
            try checkStandardKeys(dict: rawCategory, type: "assembledItems")
            
            guard let partsStrings = rawCategory.value(forKey: Parser.partsKey) as? [String] else {
                let message = String(format: errorMessage, arguments: [Parser.partsKey, "[String]"])
                throw GameConfigError.formatError(message: message)
            }
            guard let partsImageStrings = rawCategory.value(forKey: Parser.partsImageStringsKey) as? [String: [String]]
                else {
                let message = String(format: errorMessage, arguments: [Parser.partsImageStringsKey, "[String: [String]]"])
                throw GameConfigError.formatError(message: message)
            }
            // check whether each part is assigned an array of Strings
            let AreAllPartsAssignedImages = Set(partsStrings) == Set(partsImageStrings.keys)
            if !AreAllPartsAssignedImages {
                let message = "Not every part is assigned an array of Strings in assembledItems."
                throw GameConfigError.formatError(message: message)
            }
            
            if rawCategory.value(forKey: Parser.depthKey) as? Int == nil {
                let message = String(format: errorMessage, arguments: [Parser.depthKey, "Int"])
                throw GameConfigError.formatError(message: message)
            }
            if rawCategory.value(forKey: Parser.mainImageStringKey) as? String == nil {
                let message = String(format: errorMessage, arguments: [Parser.mainImageStringKey, "String"])
                throw GameConfigError.formatError(message: message)
            }
        }

    }
    
    // Checks whether "category", "isInventoryItem" and "isOrderItem" keys and their values are formatted correctly.
    private static func checkStandardKeys(dict: NSDictionary, type: String) throws {
        let errorMessage = "%@ under \(type) cannot be cast to %@."
        if dict.value(forKey: Parser.categoryKey) as? String == nil {
            let message = String(format: errorMessage, arguments: [Parser.categoryKey, "String"])
            throw GameConfigError.formatError(message: message)
        }
        if dict.value(forKey: Parser.isInventoryItemKey) as? Bool == nil {
            let message = String(format: errorMessage, arguments: [Parser.isInventoryItemKey, "Boolean"])
            throw GameConfigError.formatError(message: message)
        }
        if dict.value(forKey: Parser.isOrderItemKey) as? Bool == nil {
            let message = String(format: errorMessage, arguments: [Parser.isOrderItemKey, "Boolean"])
            throw GameConfigError.formatError(message: message)
        }
    }
    
}

enum GameConfigError: Error {
    case formatError(message: String)
}
