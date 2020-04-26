//
//  GameControllerModelManager.swift
//  Relentless
//
//  Created by Chow Yi Yin on 12/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

extension GameControllerManager {

    var openedPackage: Package? {
        game?.currentlyOpenPackage
    }

    func addNewPackage() {
        game?.addNewPackage()
    }

    func addItem(item: Item) {
        game?.addItem(item: item)
    }

    func removeItem(item: Item) {
        game?.removeItem(item: item)
    }

    func removePackage(package: Package) {
        game?.removePackage(package: package)
    }

    func deliverPackage(package: Package, to house: House) {
        guard let isCorrect = game?.checkPackage(package: package, for: house) else {
            return
        }
        guard let order = game?.retrieveOrder(package: package, house: house) else {
            return
        }
        removePackage(package: package)
        removeOrder(order: order)
        updateSatisfaction(order: order, package: package, isCorrect: isCorrect)
        notifyDeliverySuccess(isCorrect: isCorrect)
    }
    
    private func notifyDeliverySuccess(isCorrect: Bool) {
        if isCorrect {
            NotificationCenter.default.post(name: .correctDelivery, object: nil)
        } else {
            NotificationCenter.default.post(name: .wrongDelivery, object: nil)
        }
    }

    func openPackage(package: Package) {
        game?.openPackage(package: package)
    }

    func retrieveActiveOrders(for house: House) -> [Order] {
        guard let orders = game?.retrieveOrders(for: house) else {
            return []
        }
        return orders.filter { $0.hasStarted }
    }

    func retrieveItemsFromOpenPackage() -> [Item] {
        game?.currentlyOpenPackage?.items ?? []
    }

    func retrieveOpenPackage() -> Package? {
        game?.currentlyOpenPackage
    }

    func constructAssembledItem(parts: [Item]) throws {
        let imageRepresentationMapping = itemSpecifications.assembledItemImageRepresentationMapping
//        let statefulItemRepresentationMapping = itemSpecifications.itemIdentifierToImageRepresentationMappings
        try game?.constructAssembledItem(parts: parts,
                                         imageRepresentationMapping: imageRepresentationMapping)
//                                         statefulItemImageRepresentationMapping: statefulItemRepresentationMapping)
    }
    
    internal func removeOrder(order: Order) {
        game?.removeOrder(order: order)
        let hasNoMoreOrders = houses.flatMap { $0.orders }.isEmpty
        if hasNoMoreOrders {
            // wait for view to segue back to packing screen
            Timer.scheduledTimer(timeInterval: 1,
                                 target: self,
                                 selector: #selector(outOfOrders),
                                 userInfo: nil, repeats: false)
        }
    }

    /// To inform the network that this player has run out of orders
    @objc internal func outOfOrders() {
        guard let gameId = gameId, let userId = userId else {
            return
        }
        network.outOfOrders(userId: userId, gameId: gameId)

    }

    /// Assigns orders to houses and sets the houses in Game to this new list of houses
    internal func initialiseHouses(with orders: [Order]) {
         guard let parameters = gameParameters else {
             return
         }
         let numOfHouses = parameters.numOfHouses
         var splitOrders = [[Order]]()
         for _ in 1...numOfHouses {
            splitOrders.append([])
         }
         for i in 0..<orders.count {
            splitOrders[i % numOfHouses].append(orders[i])
         }
         var houses = [House]()
         for orders in splitOrders {
             let satisfactionFactor = Double.random(in: parameters.houseSatisfactionFactorRange)
             var ordersForHouse = Set<Order>()
             for order in orders {
                 let originalTimeLimit = order.timeLimit
                 let newTimeLimit = Int(Double(originalTimeLimit) * satisfactionFactor)
                 let newOrder = Order(items: order.items, timeLimitInSeconds: newTimeLimit)
                 ordersForHouse.insert(newOrder)
             }
             houses.append(House(orders: Set(ordersForHouse), satisfactionFactor: satisfactionFactor))
         }
         game?.houses = houses
    }
}
