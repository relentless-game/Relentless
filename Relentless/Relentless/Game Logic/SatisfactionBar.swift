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
    var startingSatisfaction: Int
    var defaultSatisfactionChange: Int

    init(minSatisfaction: Int, maxSatisfaction: Int) {
        satisfactionRange = minSatisfaction...maxSatisfaction
        startingSatisfaction = (maxSatisfaction + minSatisfaction) / 2
        currentSatisfaction = startingSatisfaction
        defaultSatisfactionChange = Int(0.4 * Float(currentSatisfaction))
    }

    /// Updates satisfaction value based on correctness of order fulfilment and time used
    func update(order: Order, isCorrect: Bool) {
        let remainingTime = order.timeLeft
        let totalTime = order.timeLimit

        if isCorrect {
            let fraction = remainingTime / totalTime
            currentSatisfaction += fraction * defaultSatisfactionChange
            if currentSatisfaction > 100 {
                currentSatisfaction = 100
            }
        } else {
            let fraction = (1 - remainingTime) / totalTime
            currentSatisfaction -= fraction * defaultSatisfactionChange
        }
    }

    func reset() {
        currentSatisfaction = startingSatisfaction
    }

    // todo: allow different changes to satisfaction based on the order/house
    func updateForTimeOut() {
        currentSatisfaction -= defaultSatisfactionChange
    }

}
