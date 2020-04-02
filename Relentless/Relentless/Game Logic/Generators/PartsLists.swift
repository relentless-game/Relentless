//
//  PermutationsLists.swift
//  Relentless
//
//  Created by Chow Yi Yin on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
class PartsLists {

    static var toyCarWheels: [ToyCarWheel] {
        let shapes = Shape.allCases
        var wheels = [ToyCarWheel]()
        for shape in shapes {
            wheels.append(ToyCarWheel(shape: shape))
        }
        return wheels
    }
    static var toyCarBatteries: [ToyCarBattery] {
        let labels = Label.allCases
        var batteries = [ToyCarBattery]()
        for label in labels {
            batteries.append(ToyCarBattery(label: label))
        }
        return batteries
    }
    static var toyCarBodies: [ToyCarBody] {
        let colours = Colour.allCases
        var bodies = [ToyCarBody]()
        for colour in colours {
            bodies.append(ToyCarBody(colour: colour))
        }
        return bodies
    }
}
