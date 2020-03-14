//
//  Game.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol Game {

    var player: Player? { get set }
    var id: Int { get set }

    func addPackage(package: Package)

    func removePackage(package: Package)

    func addItem(item: Item)

    func removeItem(item: Item)

    func checkPackage(package: Package, for house: House) -> Bool

    func addOtherPlayer(player: Player)

    func removeOtherPlayer(player: Player)

    func retrieveOrders(for house: House) -> [Order]

}
