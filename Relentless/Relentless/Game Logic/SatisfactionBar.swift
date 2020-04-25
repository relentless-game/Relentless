//
//  SatisfactionBar.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class SatisfactionBar {

    private var startingSatisfaction: Double

    var satisfactionRange: ClosedRange<Double>
    var currentSatisfaction: Double {
        didSet {
            NotificationCenter.default.post(name: .didChangeCurrentSatisfaction, object: nil)
        }
    }

    // Returns a float from 0...1
    var currentFractionalSatisfaction: Double {
        let range = satisfactionRange.upperBound - satisfactionRange.lowerBound
        let adjustedCurrentSatisfaction = currentSatisfaction - Double(satisfactionRange.lowerBound)
        return Double(adjustedCurrentSatisfaction) / Double(range)
    }

    init(range: ClosedRange<Double>) {
        self.satisfactionRange = range
        startingSatisfaction = satisfactionRange.upperBound
        currentSatisfaction = Double(startingSatisfaction)
    }

    /// Updates satisfaction value based on given expression
    func update(order: Order, package: Package?, isCorrect: Bool, expression: (([String: Double]) -> Double?)?) {

        guard let change = generateSatisfactionChange(order: order, package: package,
                                                      isCorrect: isCorrect, expression: expression) else {
            return
        }
        updateSatisfactionValue(valueChange: change)
    }

    func reset() {
        currentSatisfaction = Double(startingSatisfaction)
    }

    func decrement(amount: Double) {
        currentSatisfaction -= amount
    }

    private func generateSatisfactionChange(order: Order, package: Package?, isCorrect: Bool,
                                            expression: (([String: Double]) -> Double?)?) -> Double? {
        if expression == nil {
            return calculateSatisfactionChange(order: order, package: package, isCorrect: isCorrect)
        } else {
            return calculateSatisfactionChange(order: order, package: package, expression: expression)
        }
    }

    private func updateSatisfactionValue(valueChange: Double) {
        currentSatisfaction += valueChange

        if currentSatisfaction > 100 {
            currentSatisfaction = 100
        }

        if currentSatisfaction < 0 {
            currentSatisfaction = 0
        }
    }

    /// Calculate satisfaction change based on correctness of package, the amount of time taken
    /// and the number of correct items
    private func calculateSatisfactionChange(order: Order, package: Package?,
                                             expression: (([String: Double]) -> Double?)?) -> Double? {
        guard let expression = expression else {
            return nil
        }
        let varDict = [VariableNames.totalTime: Double(order.timeLimit),
                       VariableNames.timeLeft: Double(order.timeLeft),
                       VariableNames.numOfDifferences: Double(getNumberOfDifferences(package: package, order: order)),
                       VariableNames.numOfItems: Double(order.items.count)]
        return expression(varDict)
    }

    /// Default implementation that calculates satisfaction change based on correctness of package,
    /// the amount of time taken and the number of correct items
    private func calculateSatisfactionChange(order: Order, package: Package?, isCorrect: Bool) -> Double {
        let remainingTime = Float(order.timeLeft)
        let totalTime = Float(order.timeLimit)
        let defaultSatisfactionChange: Float = 25
        let defaultSatisfactionIncreaseForCorrectItem: Float = 1

        if isCorrect && package != nil {
            return handleCorrectPackage(remainingTime: remainingTime, totalTime: totalTime, order: order,
                                        satisfactionChange: defaultSatisfactionChange,
                                        unitSatisfactionIncrease: defaultSatisfactionIncreaseForCorrectItem)
        } else {
            return handleWrongPackage(totalTime: totalTime, remainingTime: remainingTime, order: order,
                                      package: package, satisfactionChange: defaultSatisfactionChange,
                                      unitSatisfactionIncrease: defaultSatisfactionIncreaseForCorrectItem)
        }
    }

    private func handleCorrectPackage(remainingTime: Float, totalTime: Float, order: Order,
                                      satisfactionChange: Float, unitSatisfactionIncrease: Float) -> Double {
        let timeProportionLeft = remainingTime / totalTime
        let numberOfCorrectItems = order.items.count
        let increase = satisfactionChange * timeProportionLeft + Float(numberOfCorrectItems)
            * unitSatisfactionIncrease
        return Double(increase)
    }

    private func handleWrongPackage(totalTime: Float, remainingTime: Float, order: Order,
                                    package: Package?, satisfactionChange: Float,
                                    unitSatisfactionIncrease: Float) -> Double {
        let numOfDifferences = getNumberOfDifferences(package: package, order: order)
        let timeProportionUsed = (totalTime - remainingTime) / totalTime
        let decrease = satisfactionChange * timeProportionUsed + Float(numOfDifferences / order.items.count)
            * unitSatisfactionIncrease
        return Double(-decrease)
    }

    private func getNumberOfDifferences(package: Package?, order: Order) -> Int {
        guard let package = package else {
            return 0
        }
        let numOfDifferences = order.getNumberOfDifferences(with: package)
        return numOfDifferences
    }

}
