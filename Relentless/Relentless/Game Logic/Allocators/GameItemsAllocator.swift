//
//  GameItemsGenerator.swift
//  Relentless
//
//  Created by Chow Yi Yin on 11/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// Generates items based on the given categories and allocates them to the given players.
protocol GameItemsAllocator {

   func allocateItems(inventoryItems: [Item], to players: [Player])

}
