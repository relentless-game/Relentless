//
//  GameManager.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// This is the implementation class of the `Game` protocol, which handles models in the game.
class GameManager: Game {
        
    /// user information
    var player: Player
    var allPlayers = [Player]()
    var numberOfPlayers: Int {
        allPlayers.count
    }

    /// game information
    var gameId: Int
    var roundItemSpecifications: RoundItemSpecifications?
    var packages = [Package]() {
        didSet {
            NotificationCenter.default.post(name: .didChangePackagesInModel, object: nil)
        }
    }
    var houses = [House]()
    var cumulativePackageNumber = 0
    var currentlyOpenPackage: Package? {
        didSet {
            NotificationCenter.default.post(name: .didChangeOpenPackageInModel, object: nil)
        }
    }
    var currentRoundNumber = 0
    var packageItemsLimit: Int?

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
        let emptyPackage = Package(creator: player.userName, creatorAvatar: player.profileImage,
                                   packageNumber: cumulativePackageNumber, items: [Item](),
                                   itemsLimit: packageItemsLimit)
        packages.append(emptyPackage)
        currentlyOpenPackage = emptyPackage
        cumulativePackageNumber += 1
    }

    /// Removes the package if it exists. Else, do nothing.
    func removePackage(package: Package) {
        guard let indexOfPackage = packages.firstIndex(of: package) else {
            return
        }
        if currentlyOpenPackage == package {
            currentlyOpenPackage = nil
        }
        packages.remove(at: indexOfPackage)
    }

    func addItem(item: Item) {
        currentlyOpenPackage?.addItem(item: item)
    }

    func removeItem(item: Item) {
        currentlyOpenPackage?.removeItem(item: item)
    }

    func constructAssembledItem(parts: [Item], imageRepresentationMapping: [Category: ImageRepresentation]) throws {
        guard let roundItemSpecifications = self.roundItemSpecifications else {
            return
        }
        let partsMapping =
            roundItemSpecifications.partsToAssembledItemCategoryMapping
        let assembledItem = try ItemAssembler.assembleItem(parts: parts,
                                                           partsToAssembledItemCategoryMapping: partsMapping,
                                                           imageRepresentationMapping: imageRepresentationMapping)
        for part in parts {
            currentlyOpenPackage?.removeItem(item: part)
        }
        currentlyOpenPackage?.addItem(item: assembledItem)
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

    func resetForNewRound() {
        houses = [House]()
        packages = [Package]()
        cumulativePackageNumber = 0
        currentlyOpenPackage = nil
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(notifyItemChange(notification:)),
                                               name: .didChangeItemsInPackage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notifyOrderUpdate(notification:)),
                                               name: .didOrderUpdateInHouse, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notifyOrderTimeOut(notification:)),
                                               name: .didTimeOutInOrder, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notifyItemLimitReached(notification:)),
                                               name: .didItemLimitReachedInPackage, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notifyOrderTimeChange(notification:)),
                                               name: .didTimeUpdateInOrder, object: nil)
    }

    @objc
    func notifyItemChange(notification: Notification) {
        NotificationCenter.default.post(name: .didChangeItemsInModel, object: nil)
    }

    @objc
    func notifyOrderUpdate(notification: Notification) {
        NotificationCenter.default.post(name: .didOrderUpdateInModel, object: nil)
    }

    @objc
    func notifyOrderTimeOut(notification: Notification) {
        NotificationCenter.default.post(name: .didOrderTimeOutInModel, object: nil)
    }

    @objc
    func notifyItemLimitReached(notification: Notification) {
        NotificationCenter.default.post(name: .didItemLimitReachedInModel, object: nil)
    }

    @objc
    func notifyOrderTimeChange(notification: Notification) {
        NotificationCenter.default.post(name: .didOrderTimeUpdateInModel, object: nil)
    }

}
