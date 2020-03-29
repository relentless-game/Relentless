//
//  PermutationsLists.swift
//  Relentless
//
//  Created by Chow Yi Yin on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
class PartsLists {

    static let toyCarWheels = [ToyCarWheel(radius: 1.0), ToyCarWheel(radius: 2.5)]
    static let toyCarBatteries = [ToyCarBattery(label: "AA"), ToyCarBattery(label: "AAA")]
    static var toyCarBodies: [ToyCarBody] {
        let colours = Colour.allCases
        var bodies = [ToyCarBody]()
        for colour in colours {
            bodies.append(ToyCarBody(colour: colour))
        }
        return bodies
    }
}
