//
//  Player.swift
//  Relentless
//
//  Created by Liu Zechu on 13/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
import UIKit

/// This struct represents a player in the game.
class Player {
    let userId: String
    let userName: String
    let profileImage: UIImage?
    var items: Set<Item> = []
    var orders: Set<Order> = []

    init(userId: String, userName: String, profileImage: UIImage?) {
        self.userId = userId
        self.userName = userName
        self.profileImage = profileImage
    }
}

extension Player: Equatable {
    static func ==(lhs: Player, rhs: Player) -> Bool {
        lhs.userId == rhs.userId &&
        lhs.userName == rhs.userName &&
        lhs.profileImage == rhs.profileImage
    }
}
