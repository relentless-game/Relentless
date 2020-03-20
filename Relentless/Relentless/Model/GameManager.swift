//
//  GameManager.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class GameManager: Game {
        
    /// user information
    var player: Player
    var allPlayers = [Player]()
    var numberOfPlayers: Int {
        allPlayers.count
    }

    /// game information
    let defaultNumberOfHouses = 5 // todo: should be changeable
    var gameId: Int
    var packages = [Package]() {
        didSet {
            NotificationCenter.default.post(name: .didChangePackagesInModel, object: nil)
        }
    }
    var houses = [House]()
    var cumulativePackageNumber = 0
    var currentlyOpenPackage: Package?
    var currentRoundNumber = 0

    init(gameId: Int, player: Player) {
        self.gameId = gameId
        self.player = player
        addObservers()
    }

    func addPackage(package: Package) {
        packages.append(package)
    }

    /// Adds a new package and sets this package as the currenlty open package
    func addNewPackage() {
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

    func removeOrder(order: Order) {
        for house in houses {
            house.removeOrder(order: order)
        }
    }

    func openPackage(package: Package) {
        assert(packages.contains(package))
        currentlyOpenPackage = package
    }

    func incrementRoundNumber() {
        currentRoundNumber += 1
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(notifyItemChange(notification:)), name: .didChangeItemsInPackage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notifyOrderUpdate(notification:)), name: .didOrderUpdateInHouse, object: nil)
    }

    @objc func notifyItemChange(notification: Notification) {
        NotificationCenter.default.post(name: .didChangeItemsInModel, object: nil)
    }

    @objc func notifyOrderUpdate(notification: Notification) {
        NotificationCenter.default.post(name: .didOrderUpdateInModel, object: nil)
    }

}
