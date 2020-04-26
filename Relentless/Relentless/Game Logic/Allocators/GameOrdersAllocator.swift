//
//  GameOrdersAllocator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// Generates orders based on the given items and allocates them to the given players.
protocol GameOrdersAllocator {

    func allocateOrders(orderItems: [Item], to players: [Player])

}
