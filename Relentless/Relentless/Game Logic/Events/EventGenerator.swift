//
//  EventGenerator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 4/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class EventGenerator {

    var probabilityOfEvent: Float

    init(probabilityOfEvent: Float) {
        self.probabilityOfEvent = probabilityOfEvent
    }

    func generate() -> EventType? {
        let randomNumber = Float.random(in: 0...1)
        guard randomNumber <= probabilityOfEvent else {
            return nil
        }
        return generateEvent()
    }

    private func generateEvent() -> EventType? {
        let allEvents = EventType.allCases
        if allEvents.isEmpty {
            return nil
        }
        let indexRange = 0...allEvents.count - 1
        let randomIndex = Int.random(in: indexRange)
        let eventType = allEvents[randomIndex]
        return eventType
    }

}
