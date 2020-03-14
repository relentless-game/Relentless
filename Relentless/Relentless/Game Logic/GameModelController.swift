//
//  GameModelController.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol GameModelController {

    func addItem(toAdd item: Item)

    func removeItem(toRemove item: Item)

    func addPackage(toAdd package: Package)

    func removePackage(toRemove package: Package)

    func deliverPackage(toDeliver package: Package)

    // func retrieveOrders(for house: House)
    // need `House` class

}
