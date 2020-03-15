//
//  GameManager.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class GameManager {
    /// user information
    var player: Player
    var allPlayers = [Player]()
    var numberOfPlayers: Int {
        allPlayers.count
    }

    /// game information
    var gameId: Int
    var packages = [Package]()
    var houses = [House]()
    var cumulativePackageNumber = 0
    var currentlyOpenPackage: Package?

    init(gameId: Int, player: Player) {
        self.gameId = gameId
        self.player = player
    }

    /// Adds a new package and sets this package as the currenlty open package
    func addPackage() {
        let emptyPackage = Package(creator: player.userName, packageNumber: cumulativePackageNumber, items: [Item]())
        packages.append(emptyPackage)
        currentlyOpenPackage = emptyPackage
        cumulativePackageNumber += 1
    }

    /// Removes the package if it exists. Else, do nothing.
    func removePackage(package: Package) {
        guard let indexOfPackage = packages.firstIndex(of: package) else {
            return
        }
        packages.remove(at: indexOfPackage)
    }

    func addItem(item: Item) {
        currentlyOpenPackage?.addItem(item: item)
    }

    func removeItem(item: Item) {
        currentlyOpenPackage?.removeItem(item: item)
    }

    func checkPackage(package: Package, for house: House) -> Bool {
        house.checkPackage(package: package)
    }

    func retrieveOrders(for house: House) -> Set<Order> {
        house.orders
    }

    func retrieveOrder(package: Package, house: House) -> Order? {
        house.getClosestOrder(for: package)
    }

    func openPackage(package: Package) {
        assert(packages.contains(package))
        currentlyOpenPackage = package
    }

}