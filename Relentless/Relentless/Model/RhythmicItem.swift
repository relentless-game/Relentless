//
//  RhythmicItem.swift
//  Relentless
//
//  Created by Yi Wai Chow on 26/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class RhythmicItem: Item {

    // represents the duration (in seconds) for each state of the rhythm
    var unitDuration: Int

    // represents the sequence of states that make up the rhythm
    var stateSequence: [RhythmState]

    // represents image strings for each rhythm state, where the string at index n is for rhythm state n.
    let imageStrings: [String]
    
    init(unitDuration: Int, stateSequence: [RhythmState], category: Category,
         isInventoryItem: Bool, isOrderItem: Bool, imageStrings: [String]) {
        self.unitDuration = unitDuration
        self.stateSequence = stateSequence
        self.imageStrings = imageStrings
        super.init(itemType: .rhythmicItem, category: category,
                   isInventoryItem: isInventoryItem, isOrderItem: isOrderItem)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RhythmicItemKeys.self)
        self.unitDuration = try container.decode(Int.self, forKey: .unitDuration)
        self.stateSequence = try container.decode([RhythmState].self, forKey: .stateSequence)
        self.imageStrings = try container.decode([String].self, forKey: .imageStrings)
        
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RhythmicItemKeys.self)
        try container.encode(unitDuration, forKey: .unitDuration)
        try container.encode(stateSequence, forKey: .stateSequence)
        try container.encode(imageStrings, forKey: .imageStrings)

        try super.encode(to: encoder)
    }

    override func isLessThan(other: Item) -> Bool {
        guard let otherItem = other as? RhythmicItem else {
            assertionFailure("other item should be of type RhythmicItem")
            return false
        }
        assert(otherItem.category == self.category)
        if unitDuration < otherItem.unitDuration {
            return true
        } else {
            return checkStatesAreLessThan(otherItem: otherItem)
        }
    }

    private func checkStatesAreLessThan(otherItem: RhythmicItem) -> Bool {
        if self.stateSequence.count < otherItem.stateSequence.count {
            return true
        } else if self.stateSequence.count > otherItem.stateSequence.count {
            return false
        } else {
            var numberOfStatesThatAreLessThanOther = 0
            var numberOfStatesThatAreMoreThanOther = 0
            let numberOfStates = self.stateSequence.count
            for counter in 0..<numberOfStates {
                let ownPart = self.stateSequence[counter]
                let otherPart = self.stateSequence[counter]
                if ownPart < otherPart {
                    numberOfStatesThatAreLessThanOther += 1
                } else {
                    numberOfStatesThatAreMoreThanOther += 1
                }
            }
            return numberOfStatesThatAreLessThanOther < numberOfStatesThatAreMoreThanOther
        }
    }

    override func hash(into hasher: inout Hasher) {
        hasher.combine(category)
        hasher.combine(unitDuration)
        hasher.combine(stateSequence)
    }

    override func toString() -> String {
        ""
    }

    override func equals(other: Item) -> Bool {
        guard let otherItem = other as? RhythmicItem else {
            print("here")
            return false
        }
        print("cat \(self.category == otherItem.category)")
        print("unit duration \(self.unitDuration == otherItem.unitDuration)")
        print("state seq \(self.stateSequence == otherItem.stateSequence)")
        return self.category == otherItem.category &&
            self.unitDuration == otherItem.unitDuration &&
            self.stateSequence == otherItem.stateSequence
    }
}

enum RhythmicItemKeys: CodingKey {
    case unitDuration
    case stateSequence
    case imageStrings
}
