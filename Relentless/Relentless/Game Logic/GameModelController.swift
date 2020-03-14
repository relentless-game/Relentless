//
//  GameModelController.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol GameModelController {

    func addItem(item: Item)

    func removeItem(item: Item)

    func addPackage(package: Package)

    func removePackage(package: Package)

    func deliverPackage(package: Package, to house: House)

    func addOtherPlayer(player: Player)

    func removeOtherPlayer(player: Player)

    func retrieveOrders(for house: House) -> [Order]

}
