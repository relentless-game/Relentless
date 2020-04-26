//
//  SatisfactionBarTests.swift
//  RelentlessTests
//
//  Created by Yi Wai Chow on 24/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class SatisfactionBarTests: XCTestCase {
    var satisfactionBar: SatisfactionBar!
    var order: Order!

    override func setUp() {
        super.setUp()
        let defaultSatisfactionRange: ClosedRange<Double> = 0...100
        satisfactionBar = SatisfactionBar(range: defaultSatisfactionRange)

        /// Initialise order
        let defaultName = "book"
        let defaultImageString = ImageRepresentation(imageStrings: ["book"])
        let defaultNameTwo = "magazine"
        let defaultImageStringTwo = ImageRepresentation(imageStrings: ["magazine"])
        let items = [TitledItem(name: defaultName,
                                category: Category(name: "book"),
                                isInventoryItem: true,
                                isOrderItem: true,
                                imageRepresentation: defaultImageString),
                     TitledItem(name: defaultNameTwo,
                                category: Category(name: "magazine"),
                                isInventoryItem: true,
                                isOrderItem: true,
                                imageRepresentation: defaultImageStringTwo)]
        order = Order(items: items, timeLimitInSeconds: 5)
    }

    func testConstruction() {
        XCTAssertEqual(satisfactionBar.currentSatisfaction, 100)
    }

    func testInitialSatisfactionValue() {
        XCTAssertEqual(satisfactionBar.currentSatisfaction, 100)
    }

    func testFractionalSatisfactionValue() {
        XCTAssertEqual(satisfactionBar.currentFractionalSatisfaction, 1)

        satisfactionBar.decrement(amount: 20)
        XCTAssertEqual(satisfactionBar.currentFractionalSatisfaction, 0.8)
    }

    func testUpdate_correctPackage_nilExpression_satisfactionIncrease() {
        satisfactionBar.decrement(amount: 50)
        let originalSatisfaction = satisfactionBar.currentSatisfaction

        let defaultCreator = "creator"
        let defaultAvatar = PlayerAvatar(rawValue: "red")!
        let defaultPackageNumber = 0
        let items = order.items

        let package = Package(creator: defaultCreator,
                              creatorAvatar: defaultAvatar,
                              packageNumber: defaultPackageNumber,
                              items: items, itemsLimit: nil)
        order.startOrder()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
            self.satisfactionBar.update(order: self.order, package: package, isCorrect: true, expression: nil)
            let updatedSatisfaction = self.satisfactionBar.currentSatisfaction
            XCTAssertTrue(originalSatisfaction < updatedSatisfaction)
        })
    }

    func testUpdate_correctPackage_nilExpression_timeDependence() {
        satisfactionBar.decrement(amount: 50)

        let defaultCreator = "creator"
        let defaultAvatar = PlayerAvatar(rawValue: "red")!
        let defaultPackageNumber = 0
        let items = order.items

        let package = Package(creator: defaultCreator,
                              creatorAvatar: defaultAvatar,
                              packageNumber: defaultPackageNumber,
                              items: items, itemsLimit: nil)

        order.startOrder()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
            self.satisfactionBar.update(order: self.order, package: package, isCorrect: true, expression: nil)
            let updatedSatisfaction = self.satisfactionBar.currentSatisfaction

            self.satisfactionBar.reset()
            self.satisfactionBar.decrement(amount: 50)
            let newOrder = Order(items: items, timeLimitInSeconds: 5)
            newOrder.startOrder()
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { _ in
                self.satisfactionBar.update(order: newOrder, package: package, isCorrect: true, expression: nil)
                let updatedSatisfactionLessIncrease = self.satisfactionBar.currentSatisfaction
                XCTAssertTrue(updatedSatisfactionLessIncrease < updatedSatisfaction)
            })
        })
    }

    func testUpdate_wrongPackage_nilExpression_satisfactionDecrease() {
        satisfactionBar.decrement(amount: 50)
        let originalSatisfaction = satisfactionBar.currentSatisfaction

        let defaultCreator = "creator"
        let defaultAvatar = PlayerAvatar(rawValue: "red")!
        let defaultPackageNumber = 0
        var items = order.items
        items.remove(at: 0)

        let package = Package(creator: defaultCreator,
                              creatorAvatar: defaultAvatar,
                              packageNumber: defaultPackageNumber,
                              items: items, itemsLimit: nil)
        order.startOrder()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
            self.satisfactionBar.update(order: self.order, package: package, isCorrect: false, expression: nil)
            let updatedSatisfaction = self.satisfactionBar.currentSatisfaction
            XCTAssertTrue(originalSatisfaction > updatedSatisfaction)
        })
    }

    func testUpdate_wrongPackage_nilExpression_timeDependence() {
        satisfactionBar.decrement(amount: 50)

        let defaultCreator = "creator"
        let defaultAvatar = PlayerAvatar(rawValue: "red")!
        let defaultPackageNumber = 0
        var items = order.items
        items.remove(at: 0)

        let package = Package(creator: defaultCreator,
                              creatorAvatar: defaultAvatar,
                              packageNumber: defaultPackageNumber,
                              items: items, itemsLimit: nil)

        order.startOrder()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
            self.satisfactionBar.update(order: self.order, package: package, isCorrect: true, expression: nil)
            let updatedSatisfaction = self.satisfactionBar.currentSatisfaction

            self.satisfactionBar.reset()
            self.satisfactionBar.decrement(amount: 50)
            let newOrder = Order(items: items, timeLimitInSeconds: 5)
            newOrder.startOrder()
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { _ in
                self.satisfactionBar.update(order: newOrder, package: package, isCorrect: true, expression: nil)
                let updatedSatisfactionLessDecrease = self.satisfactionBar.currentSatisfaction
                XCTAssertTrue(updatedSatisfactionLessDecrease > updatedSatisfaction)
            })
        })
    }

    func testReset() {
        let originalSatisfaction = satisfactionBar.currentSatisfaction
        satisfactionBar.decrement(amount: 30)
        satisfactionBar.reset()
        let resetSatisfaction = satisfactionBar.currentSatisfaction
        XCTAssertEqual(resetSatisfaction, originalSatisfaction)
    }

    func testDecrement() {
        let originalSatisfaction = satisfactionBar.currentSatisfaction
        satisfactionBar.decrement(amount: 30)
        let expectedSatisfaction: Double = 70
        let updatedSatisfaction = satisfactionBar.currentSatisfaction
        XCTAssertEqual(updatedSatisfaction, expectedSatisfaction)
    }

}
