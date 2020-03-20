//
//  GameModelController.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// To handle `Model` related game actions
protocol GameModelController {

    var game: Game? { get set }
    var players: [Player] { get }
    var playerPackages: [Package] { get }
    var playerItems: [Category: [Item]] { get }

    func addItem(item: Item)

    func removeItem(item: Item)

    func removePackage(package: Package)

    func deliverPackage(package: Package, to house: House)

    func openPackage(package: Package)

    func retrieveOrders(for house: House) -> Set<Order>

}
