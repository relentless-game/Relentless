//
//  ItemGenerator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol GameItemsAllocator {

    func generateItems() -> [Item]

    func allocateItems(players: [Player])

}
