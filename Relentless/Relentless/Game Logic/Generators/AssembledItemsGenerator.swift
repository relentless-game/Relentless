//
//  PermutationBasedGenerator.swift
//  Relentless
//
//  Created by Chow Yi Yin on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class AssembledItemsGenerator: ItemGenerator {

    static func generateItems(category: Category, numberToGenerate: Int) -> [Item] {
        switch category {
        case Category.toyCar:
            return createToyCars(numberToGenerate: numberToGenerate)
        default:
            return []
        }
    }

    private static func createToyCars(numberToGenerate: Int) -> [ToyCar] {
        var toyCars = Set<ToyCar>()
        var numberOfCarsNeeded = numberToGenerate
        let totalNumberOfCombinations = calculateTotalCombinations(partTypes: ToyCar.partTypesNeeded)
        if totalNumberOfCombinations < numberToGenerate {
            numberOfCarsNeeded = totalNumberOfCombinations
        }
        while toyCars.count < numberOfCarsNeeded {
            guard let toyCar = createToyCar() else {
                continue
            }
            toyCars.insert(toyCar)

        }
        return Array(toyCars)
    }

    private static func createToyCar() -> ToyCar? {
        guard let wheel = selectWheel(), let battery = selectBattery(), let toyCarBody = selectToyCarBody() else {
            return nil
        }
        return ToyCar(wheel: wheel, battery: battery, toyCarBody: toyCarBody)
    }

    private static func selectWheel() -> Wheel? {
        guard let wheel = randomSelect(list: PartsLists.wheels) as? Wheel else {
            return nil
        }
        return wheel
    }

    private static func selectBattery() -> Battery? {
        guard let battery = randomSelect(list: PartsLists.batteries) as? Battery else {
            return nil
        }
        return battery
    }

    private static func selectToyCarBody() -> ToyCarBody? {
        guard let toyCarBody = randomSelect(list: PartsLists.toyCarBodies) as? ToyCarBody else {
            return nil
        }
        return toyCarBody
    }

    private static func randomSelect(list: [Any]) -> Any {
        let range = 0..<list.count
        let randomNumber = Int.random(in: range)
        return list[randomNumber]
    }

    private static func calculateTotalCombinations(partTypes: [PartType]) -> Int {
        var numberOfCombininations = 1
        for partType in partTypes {
            switch partType {
            case PartType.wheel:
                numberOfCombininations *= PartsLists.wheels.count
            case PartType.battery:
                numberOfCombininations *= PartsLists.batteries.count
            case PartType.toyCarBody:
                numberOfCombininations *= PartsLists.toyCarBodies.count
            default:
                continue
            }
        }
        return numberOfCombininations
    }

}
