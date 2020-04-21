//
//  AppreciationEvent.swift
//  Relentless
//
//  Created by Yi Wai Chow on 4/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class AppreciationEvent: Event {

    var duration = 30

    let satisfactionIncrease: Double = 10
    
    /// For 30 seconds, the default satisfaction change will increase
    func occur() {
        increaseSatisfactionChange()
        Timer.scheduledTimer(timeInterval: TimeInterval(duration), target: self,
                             selector: #selector(resetSatisfactionChange), userInfo: nil,
                             repeats: false)
    }

    func increaseSatisfactionChange() {
        //gameParameters.satisfactionUnitDecrease -= satisfactionIncrease
    }

    @objc
    func resetSatisfactionChange() {
        //gameParameters.defaultSatisfactionChange += satisfactionIncrease
    }

}
