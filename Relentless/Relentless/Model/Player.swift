//
//  Player.swift
//  Relentless
//
//  Created by Liu Zechu on 13/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// This struct represents a player (which is not the user itself) in the game.
class Player: Equatable {

    let userId: String
    var items = Set<Item>()
    var orders = Set<Order>()

    init(userId: String) {
        self.userId = userId
    }

    static func == (lhs: Player, rhs: Player) -> Bool {
        // to change
        return true
    }


}
