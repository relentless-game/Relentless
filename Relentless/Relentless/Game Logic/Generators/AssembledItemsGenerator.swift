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
        let totalNumberOfCombinations = calculateTotalCombinations(partTypesAndFrequency:
            ToyCar.partTypesAndFrequencies)
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
        guard let wheel = selectToyCarWheel(), let battery = selectToyCarBattery(),
            let toyCarBody = selectToyCarBody() else {
            return nil
        }
        return ToyCar(wheel: wheel, battery: battery, toyCarBody: toyCarBody)
    }

    private static func selectToyCarWheel() -> ToyCarWheel? {
        guard let wheel = randomSelect(list: PartsLists.toyCarWheels) as? ToyCarWheel else {
            return nil
        }
        return wheel
    }

    private static func selectToyCarBattery() -> ToyCarBattery? {
        guard let battery = randomSelect(list: PartsLists.toyCarBatteries) as? ToyCarBattery else {
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

    private static func calculateTotalCombinations(partTypesAndFrequency: [(PartType, Int)]) -> Int {
        var numberOfCombininations = 1
        for partAndFrequency in partTypesAndFrequency {
            let partType = partAndFrequency.0
            let frequency = partAndFrequency.1
            switch partType {
            case PartType.toyCarWheel:
                numberOfCombininations *= choose(number: frequency, from: PartsLists.toyCarWheels.count)
            case PartType.toyCarBattery:
                numberOfCombininations *= choose(number: frequency, from: PartsLists.toyCarBatteries.count)
            case PartType.toyCarBody:
                numberOfCombininations *= choose(number: frequency, from: PartsLists.toyCarBodies.count)
            default:
                continue
            }
        }
        return numberOfCombininations
    }

    /// referenced from:
    /// https://stackoverflow.com/questions/39308300/find-the-best-way
    /// -for-combination-without-repetition-calculation-in-swift
    static func choose(number: Int, from total: Int) -> Int {
        assert(number >= 0 && total >= 0)
        if number > total {
            return 0
        }
        var result = 1
        for current in 0 ..< min(number, total - number) {
            result = (result * (total - current)) / (current + 1)
        }
        return result
    }

}
