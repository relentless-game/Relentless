//
//  OrderGenerator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol GameOrderAllocator {

    // orders are generated and allocated concurrently
    func allocateOrders(players: [Player])

}
