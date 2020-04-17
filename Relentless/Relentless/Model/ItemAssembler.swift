//
//  ItemAssembler.swift
//  Relentless
//
//  Created by Chow Yi Yin on 28/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
class ItemAssembler {
    static let imageString = "" //TODO: get image string from somewhere?

    static func assembleItem(parts: [Item],
                             partsToAssembledItemCategoryMapping: [[Category]: Category]) throws -> AssembledItem {
        let selectedCategories = parts.map { $0.category }.sorted()
        guard let categoryOfAssembledItem = partsToAssembledItemCategoryMapping[selectedCategories] else {
            throw ItemAssembledError.assembledItemConstructionError
        }
        return try createItem(parts: parts, assembledItemCategory: categoryOfAssembledItem)
    }

    private static func createItem(parts: [Item], assembledItemCategory: Category) throws ->
        AssembledItem {
        assert(!parts.isEmpty)
            return AssembledItem(parts: parts, category: assembledItemCategory,
                                 imageString: ItemAssembler.imageString)
    }

//    private static func checkIfHasCorrectNumberOfParts(parts: [Item],
//                                                       requiredPartsAndFrequencies: [(Item, Int)]) -> Bool {
//        for part in requiredPartsAndFrequencies {
//            let partType = part.0
//            let requiredNumber = part.1
//            let partsWithPartType = parts.filter { $0.partType == partType }
//            let frequency = partsWithPartType.count
//            if frequency != requiredNumber {
//                return false
//            }
//        }
//        return true
//    }
}

enum ItemAssembledError: Error {
    case assembledItemConstructionError
}
