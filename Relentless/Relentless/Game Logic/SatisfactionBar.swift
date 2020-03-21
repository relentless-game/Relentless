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
    var currentSatisfaction: Int {
        didSet {
            NotificationCenter.default.post(name: .didChangeCurrentSatisfaction, object: nil)
        }
    }
    // Returns a float from 0...1
    var currentFractionalSatisfaction: Float {
        let range = satisfactionRange.upperBound - satisfactionRange.lowerBound
        let adjustedCurrentSatisfaction = currentSatisfaction - satisfactionRange.lowerBound
        print(range)
        print(defaultSatisfactionChange)
        print(adjustedCurrentSatisfaction)
        return Float(adjustedCurrentSatisfaction) / Float(range)
    }

    var defaultSatisfactionChange: Int

    init(minSatisfaction: Int, maxSatisfaction: Int) {
        satisfactionRange = minSatisfaction...maxSatisfaction
        currentSatisfaction = (maxSatisfaction + minSatisfaction) / 2
        defaultSatisfactionChange = Int(0.4 * Float(currentSatisfaction))
    }

    /// Updates satisfaction value based on correctness of order fulfilment and time used
    func update(order: Order, isCorrect: Bool) {
        let remainingTime = Float(order.timeLeft)
        let totalTime = Float(order.timeLimit)

        if isCorrect {
            let fraction = remainingTime / totalTime
            currentSatisfaction += Int(fraction * Float(defaultSatisfactionChange))
            if currentSatisfaction > 100 {
                currentSatisfaction = 100
            }
        } else {
            let fraction = (totalTime - remainingTime) / totalTime
//            print("bef \(currentSatisfaction)")
//            print(fraction)
            currentSatisfaction -= Int(fraction * Float(defaultSatisfactionChange))
//            print("aft \(currentSatisfaction)")
        }
    }

    // todo: allow different changes to satisfaction based on the order/house
    func updateForTimeOut() {
//        print("oopy")
        currentSatisfaction -= defaultSatisfactionChange
    }

}
