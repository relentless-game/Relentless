//
//  Game.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// Handles game models.
protocol Game {

    var player: Player { get set }
    var allPlayers: [Player] { get set }
    var numberOfPlayers: Int { get }

    var gameId: Int { get set }
    var roundItemSpecifications: RoundItemSpecifications? { get set }
    var packages: [Package] { get set }
    var houses: [House] { get set }
    var currentRoundNumber: Int { get set }
    var currentlyOpenPackage: Package? { get }
    var packageItemsLimit: Int? { get set }

    /// Adds a package received from another player.
    func addPackage(package: Package)

    /// Creates a new empty package.
    func addNewPackage()
    
    func removePackage(package: Package)

    /// Adds an item into the currently open package.
    func addItem(item: Item)

    /// Removes an item from the currently open package.
    func removeItem(item: Item)

    /// Assembles constituent items into an `AssembledItem`.
    func constructAssembledItem(parts: [Item], imageRepresentationMapping: [Category: ImageRepresentation]) throws

    /// Checks whether the given package fulfills an order in the given house.
    func checkPackage(package: Package, for house: House) -> Bool

    /// Returns a set of orders from the given house.
    func retrieveOrders(for house: House) -> Set<Order> 

    /// Returns the closest order that the given package matches from the given house.
    func retrieveOrder(package: Package, house: House) -> Order?

    /// Removes the given order from the houses.
    func removeOrder(order: Order)

    /// Opens the given package so that it becomes the currently open package.
    func openPackage(package: Package)

    /// Increments the current round number.
    func incrementRoundNumber()
    
    /// Resets the houses and packages to the default states.
    func resetForNewRound()
}
