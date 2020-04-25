//
//  ItemAssembler.swift
//  Relentless
//
//  Created by Chow Yi Yin on 28/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
class ItemAssembler {
    typealias ImageRepresentationMapping = [Category: ImageRepresentation]

    static func assembleItem(parts: [Item],
                             partsToAssembledItemCategoryMapping: [[Category]: Category],
                             imageRepresentationMapping: ImageRepresentationMapping) throws -> AssembledItem {
        let dismantledParts = dismantle(parts: parts)
        let selectedCategories = dismantledParts.map { $0.category }.sorted()

        guard let categoryOfAssembledItem = partsToAssembledItemCategoryMapping[selectedCategories],
            let imageRepresentation = imageRepresentationMapping[categoryOfAssembledItem]
            as? AssembledItemImageRepresentation else {
            throw ItemAssembledError.assembledItemConstructionError
        }

        return try createItem(parts: dismantledParts, assembledItemCategory: categoryOfAssembledItem,
                              imageRepresentation: imageRepresentation)
    }

    private static func createItem(parts: [Item], assembledItemCategory: Category,
                                   imageRepresentation: AssembledItemImageRepresentation) throws -> AssembledItem {
        assert(!parts.isEmpty)
        return AssembledItem(parts: parts, category: assembledItemCategory,
                             imageRepresentation: imageRepresentation)
    }

    private static func getPartsImageStrings(parts: [Item]) -> [Category: ImageRepresentation] {
        var imageStrings = [Category: ImageRepresentation]()
        for part in parts {
            imageStrings[part.category] = part.imageRepresentation
        }
        return imageStrings
    }

    private static func dismantle(parts: [Item]) -> [Item] {
        let nonAssembledParts = parts.filter { $0 as? AssembledItem == nil }
        let assembledParts = parts.compactMap { $0 as? AssembledItem }.flatMap { $0.parts }
        var dismantledParts = nonAssembledParts
        dismantledParts.append(contentsOf: assembledParts)
        return dismantledParts
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
