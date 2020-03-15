//
//  GameItemsAllocator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol GameItemsAllocator {

    /// Allocate random items from the specified categories to the specified players
    func allocateItems(categories: [Category], players: [Player])

}
