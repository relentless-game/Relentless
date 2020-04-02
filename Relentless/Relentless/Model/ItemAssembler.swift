//
//  ItemAssembler.swift
//  Relentless
//
//  Created by Chow Yi Yin on 28/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
class ItemAssembler {

    static func assembleItem(parts: [Part]) throws -> AssembledItem {
        let isAllSameCategory = checkIfAllBelongToSameCategory(parts: parts)
        if !isAllSameCategory || parts.isEmpty {
            throw ItemAssembledError.assembledItemConstructionError
        } else {
            return try createItem(parts: parts)
        }
    }

    private static func createItem(parts: [Part]) throws -> AssembledItem {
        assert(!parts.isEmpty)
        let category = parts[0].category
        switch category {
        case Category.toyCar:
            return try createToyCar(parts: parts)
        default:
            throw ItemAssembledError.assembledItemConstructionError
        }
    }

    private static func createToyCar(parts: [Part]) throws -> ToyCar {
        let hasCorrectNumberOfItems =
            checkIfHasCorrectNumberOfParts(parts: parts,
                                           requiredPartsAndFrequencies: ToyCar.partTypesAndFrequencies)
        if !hasCorrectNumberOfItems {
            throw ItemAssembledError.assembledItemConstructionError
        } else {
            let wheel = parts.compactMap { $0 as? ToyCarWheel }.first
            let battery = parts.compactMap { $0 as? ToyCarBattery }.first
            let body = parts.compactMap { $0 as? ToyCarBody }.first
            guard let toyCarWheel = wheel, let toyCarBattery = battery, let toyCarBody = body else {
                throw ItemAssembledError.assembledItemConstructionError
            }
            return ToyCar(wheel: toyCarWheel, battery: toyCarBattery, toyCarBody: toyCarBody)
        }
    }

    private static func checkIfHasCorrectNumberOfParts(parts: [Part],
                                                       requiredPartsAndFrequencies: [(PartType, Int)]) -> Bool {
        for part in requiredPartsAndFrequencies {
            let partType = part.0
            let requiredNumber = part.1
            let partsWithPartType = parts.compactMap { $0.partType == partType }
            let frequency = partsWithPartType.count
            if frequency != requiredNumber {
                return false
            }
        }
        return true
    }

    private static func checkIfAllBelongToSameCategory(parts: [Part]) -> Bool {
        let categories = parts.map { $0.category }
        let distinctCategories = Set<Category>(categories)
        return distinctCategories.count == 1
    }
}

enum ItemAssembledError: Error {
    case assembledItemConstructionError
}
