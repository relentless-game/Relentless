//
//  SatisfactionBar.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class SatisfactionBar {

    var satisfactionRange: ClosedRange<Int>
    var currentSatisfaction: Float {
        didSet {
            NotificationCenter.default.post(name: .didChangeCurrentSatisfaction, object: nil)
        }
    }
    var startingSatisfaction: Int

    // Returns a float from 0...1
    var currentFractionalSatisfaction: Float {
        let range = satisfactionRange.upperBound - satisfactionRange.lowerBound
        let adjustedCurrentSatisfaction = currentSatisfaction - Float(satisfactionRange.lowerBound)
        return Float(adjustedCurrentSatisfaction) / Float(range)
    }

    init(minSatisfaction: Int, maxSatisfaction: Int) {
        satisfactionRange = minSatisfaction...maxSatisfaction
        startingSatisfaction = maxSatisfaction
        currentSatisfaction = Float(startingSatisfaction)
    }

    /// Updates satisfaction value based on correctness of order fulfilment and time used
    func update(order: Order, package: Package?, isCorrect: Bool) {
        let satisfactionChange = calculateSatisfactionChange(order: order, package: package, isCorrect: isCorrect)
        currentSatisfaction += satisfactionChange

        if currentSatisfaction > 100 {
            currentSatisfaction = 100
        }

        if currentSatisfaction < 0 {
            currentSatisfaction = 0
        }
    }

    func reset() {
        currentSatisfaction = Float(startingSatisfaction)
    }

    func penalise() {
        currentSatisfaction -= GameParameters.satisfactionRunOutPenalty
    }

    func decrementWithTime() {
        currentSatisfaction -= GameParameters.satisfactionUnitDecrease
    }

    /// Calculate satisfaction change based on correctness of package, the amount of time taken
    /// and the number of correct items
    private func calculateSatisfactionChange(order: Order, package: Package?, isCorrect: Bool) -> Float {
        let remainingTime = Float(order.timeLeft)
        let totalTime = Float(order.timeLimit)

        if package != nil && isCorrect {
            return handleCorrectPackage(remainingTime: remainingTime, totalTime: totalTime, order: order)
        } else {
            return handleWrongPackage(totalTime: totalTime, remainingTime: remainingTime, order: order,
                                      package: package)
        }
    }

    private func handleCorrectPackage(remainingTime: Float, totalTime: Float, order: Order) -> Float {
        let timeProportionLeft = remainingTime / totalTime
        let numberOfCorrectItems = order.items.count
        let increase = GameParameters.defaultSatisfactionChange * timeProportionLeft
            + Float(numberOfCorrectItems) * GameParameters.satisfactionIncreaseForCorrectItem
        return increase
    }

    private func handleWrongPackage(totalTime: Float, remainingTime: Float, order: Order,
                                    package: Package?) -> Float {
        let numberOfCorrectItems = getNumberOfCorrectItems(package: package, order: order)

        let timeProportionUsed = (totalTime - remainingTime) / totalTime
        let decrease = GameParameters.defaultSatisfactionChange * timeProportionUsed
            - Float(numberOfCorrectItems) * GameParameters.satisfactionIncreaseForCorrectItem
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
