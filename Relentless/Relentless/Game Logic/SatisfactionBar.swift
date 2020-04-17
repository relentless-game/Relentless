//
//  SatisfactionBar.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class SatisfactionBar {

    var satisfactionRange: ClosedRange<Float>
    var currentSatisfaction: Float {
        didSet {
            NotificationCenter.default.post(name: .didChangeCurrentSatisfaction, object: nil)
        }
    }
    var startingSatisfaction: Float

    // Returns a float from 0...1
    var currentFractionalSatisfaction: Float {
        let range = satisfactionRange.upperBound - satisfactionRange.lowerBound
        let adjustedCurrentSatisfaction = currentSatisfaction - Float(satisfactionRange.lowerBound)
        return Float(adjustedCurrentSatisfaction) / Float(range)
    }

    init(range: ClosedRange<Float>) {
        self.satisfactionRange = range
        startingSatisfaction = satisfactionRange.upperBound
        currentSatisfaction = Float(startingSatisfaction)
    }

    /// Updates satisfaction value based on given expression
    func update(order: Order, package: Package?, isCorrect: Bool, expression: (([String: Float]) -> Float?)?) {

        guard let change = generateSatisfactionChange(order: order, package: package,
                                                      isCorrect: isCorrect, expression: expression) else {
            return
        }
        updateSatisfactionValue(valueChange: change)
    }

    func reset() {
        currentSatisfaction = Float(startingSatisfaction)
    }

    func penalise(penalty: Float) {
        currentSatisfaction -= penalty
    }

    func decrementWithTime(amount: Float) {
        currentSatisfaction -= amount
    }

    private func generateSatisfactionChange(order: Order, package: Package?, isCorrect: Bool,
                                            expression: (([String: Float]) -> Float?)?) -> Float? {
        if expression == nil {
            return calculateSatisfactionChange(order: order, package: package, isCorrect: isCorrect)
        } else {
            return calculateSatisfactionChange(order: order, package: package, expression: expression)
        }
    }

    private func updateSatisfactionValue(valueChange: Float) {
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
                                             expression: (([String: Float]) -> Float?)?) -> Float? {
        guard let expression = expression else {
            return nil
        }
        let varDict = [VariableNames.totalTimeVarName: Float(order.timeLimit),
                       VariableNames.remainingTimeVarName: Float(order.timeLeft),
                       VariableNames.numOfCorrectItemsVarName: Float(getNumberOfCorrectItems(package: package,
                                                                                             order: order))]
        return expression(varDict)
    }

    /// Default implementation that calculates satisfaction change based on correctness of package,
    /// the amount of time taken and the number of correct items
    private func calculateSatisfactionChange(order: Order, package: Package?, isCorrect: Bool) -> Float {
        let remainingTime = Float(order.timeLeft)
        let totalTime = Float(order.timeLimit)
        let defaultSatisfactionChange: Float = 25
        let defaultSatisfactionIncreaseForCorrectItem: Float = 1

        if package != nil {
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
                                      satisfactionChange: Float, unitSatisfactionIncrease: Float) -> Float {
        let timeProportionLeft = remainingTime / totalTime
        let numberOfCorrectItems = order.items.count
        let increase = satisfactionChange * timeProportionLeft + Float(numberOfCorrectItems)
            * unitSatisfactionIncrease
        return increase
    }

    private func handleWrongPackage(totalTime: Float, remainingTime: Float, order: Order,
                                    package: Package?, satisfactionChange: Float,
                                    unitSatisfactionIncrease: Float) -> Float {
        let numberOfCorrectItems = getNumberOfCorrectItems(package: package, order: order)
        let timeProportionUsed = (totalTime - remainingTime) / totalTime
        let decrease = satisfactionChange * timeProportionUsed - Float(numberOfCorrectItems)
            * unitSatisfactionIncrease
        return -decrease
    }

    private func getNumberOfCorrectItems(package: Package?, order: Order) -> Int {
        guard let package = package else {
            return 0
        }
        let numberOfCorrectItems = order.items.count - order.getNumberOfDifferences(with: package)
        return numberOfCorrectItems
    }

}
