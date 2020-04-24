//
//  OrdersAllocatorTests.swift
//  RelentlessTests
//
//  Created by Chow Yi Yin on 20/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class OrdersAllocatorTests: XCTestCase {
    let maxNumOfItemsPerOrder = 3
    let numOfOrdersPerPlayer = 3
    let probabilityOfSelectingOwnItem: Float = 0.5
    let probabilityOfSelectingAssembledItem: Float = 1
    let timeForEachItem = 30
    var ordersAllocator: OrdersAllocator {
        OrdersAllocator(maxNumOfItemsPerOrder: maxNumOfItemsPerOrder,
                        numOfOrdersPerPlayer: numOfOrdersPerPlayer,
                        probabilityOfSelectingOwnItem: probabilityOfSelectingOwnItem,
                        probabilityOfSelectingAssembledItem: probabilityOfSelectingAssembledItem,
                        timeForEachItem: timeForEachItem)
    }

    func testOrderAllocation_withNonAssembledItems() {
        let itemsAndPlayers = initialiseNonAssembledItems()
        let allItems = itemsAndPlayers.0
        let players = itemsAndPlayers.1
        ordersAllocator.allocateOrders(orderItems: allItems, to: players)
        var allAllocatedOrders = [Order]()
        for player in players {
            let playerOrders = Array(player.orders)
            allAllocatedOrders.append(contentsOf: playerOrders)
            XCTAssertTrue(playerOrders.count <= numOfOrdersPerPlayer)
        }
        XCTAssertTrue(allAllocatedOrders.allSatisfy { $0.items.count <= maxNumOfItemsPerOrder })
    }

    func testOrderAllocation_withAssembledItems_canBeAssembled() {
        let itemsAndPlayers = initialiseAssembledItems()
        let allItems = itemsAndPlayers.0
        let players = itemsAndPlayers.1
        ordersAllocator.allocateOrders(orderItems: allItems, to: players)
        var allParts = [Item]()
        var allAllocatedOrders = [Order]()
        for player in players {
            let playerOrders = Array(player.orders)
            allParts.append(contentsOf: Array(player.items))
            allAllocatedOrders.append(contentsOf: playerOrders)
            XCTAssertTrue(playerOrders.count <= numOfOrdersPerPlayer)
        }
        XCTAssertTrue(allAllocatedOrders.allSatisfy { $0.items.count <= maxNumOfItemsPerOrder })

        for order in allAllocatedOrders {
            let items = order.items
            for item in items {
                guard let assembledItem = item as? AssembledItem else {
                    XCTFail("Should be assembled item...")
                    continue
                }
                XCTAssertTrue(assembledItem.parts.allSatisfy { allParts.contains($0) })
            }
        }
    }

    private func initialiseNonAssembledItems() -> ([Item], [Player]) {
        let players = [Player(userId: "1", userName: "1", profileImage: PlayerAvatar.blue),
                       Player(userId: "2", userName: "2", profileImage: PlayerAvatar.cyan)]
        var allItems = [Item]()
        var counter = 1
        let category = Category(name: "book")
        for player in players {
            let items = [TitledItem(name: String(counter), category: category,
                                    isInventoryItem: true, isOrderItem: true, imageString: ""),
                         TitledItem(name: String(counter + 1), category: category,
                                    isInventoryItem: true, isOrderItem: true, imageString: ""),
                         TitledItem(name: String(counter + 2), category: category,
                                    isInventoryItem: true, isOrderItem: true, imageString: ""),
                         TitledItem(name: String(counter + 3), category: category,
                                    isInventoryItem: true, isOrderItem: true, imageString: "")]
            counter += 4
            player.items = Set(items)
            allItems.append(contentsOf: items)
        }
        return (allItems, players)
    }

    private func initialiseAssembledItems() -> ([Item], [Player]) {
        let players = [Player(userId: "1", userName: "1", profileImage: PlayerAvatar.blue),
                       Player(userId: "2", userName: "2", profileImage: PlayerAvatar.cyan)]
        let wheels = getStatefulItem(category: Category(name: "wheel"), number: 3)
        let batteries = getStatefulItem(category: Category(name: "battery"), number: 3)
        var assembledItems = [Item]()
        for wheel in wheels {
            for battery in batteries {
                let parts = [wheel, battery]
                let partsImageStrings = [Relentless.Category: String]()
                assembledItems.append(AssembledItem(parts: parts, category: Category(name: "toyCar"),
                                                    isInventoryItem: false, isOrderItem: true,
                                                    mainImageString: "",
                                                    partsImageStrings: partsImageStrings))
            }
        }
        for counter in 0..<wheels.count {
            players[counter % players.count].items.insert(wheels[counter])
        }
        for counter in 0..<batteries.count {
            players[counter % players.count].items.insert(batteries[counter])
        }
        return (assembledItems, players)
    }

    private func getStatefulItem(category: Relentless.Category, number: Int) -> [Item] {
        var stateIdentifier = 0
        var items = [Item]()
        while stateIdentifier < number {
            items.append(StatefulItem(category: category, stateIdentifier: stateIdentifier,
                                      isInventoryItem: true, isOrderItem: false, imageString: ""))
            stateIdentifier += 1
        }
        return items
    }
}
