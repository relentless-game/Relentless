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
    var currentSatisfaction: Int

    var defaultSatisfactionChange: Int

    init(minSatisfaction: Int, maxSatisfaction: Int) {
        satisfactionRange = minSatisfaction...maxSatisfaction
        currentSatisfaction  = (maxSatisfaction + minSatisfaction) / 2
        defaultSatisfactionChange = Int(0.4 * Float(currentSatisfaction))
    }

    /// Updates satsifaction value based on correctness of order fulfilment and time used
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

    // TODO: check for satisfaction < 0 and handle this case

}
