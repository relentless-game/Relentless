//
//  RhythmState.swift
//  Relentless
//
//  Created by Yi Wai Chow on 27/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// This struct represents a state in the pattern sequence of a `RhythmicItem`,
/// where each state is indexed by an `Int`.
struct RhythmState: Codable, Hashable {

    let stateIndex: Int
    
    init(index: Int) {
        self.stateIndex = index
    }

}

extension RhythmState: Comparable {
    static func < (lhs: RhythmState, rhs: RhythmState) -> Bool {
        lhs.stateIndex < rhs.stateIndex
    }
}
