//
//  PackageTests.swift
//  RelentlessTests
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class PackageTests: XCTestCase {
    let creator = "creator"
    let packageNumber = 1
    let items = [Item]()
    let itemsLimit = 5
    var package: Package!

    let item = TitledItem(name: "1", category: Category(name: "book"),
                          isInventoryItem: true, isOrderItem: true,
                          imageRepresentation: ImageRepresentation(imageStrings: ["placeholder"]))
    
    override func setUp() {
        super.setUp()
        package = Package(creator: creator, creatorAvatar: .blue,
                          packageNumber: packageNumber, items: items, itemsLimit: itemsLimit)
    }

    func testInit() {
        let package = Package(creator: creator, creatorAvatar: .blue,
                              packageNumber: packageNumber, items: items, itemsLimit: itemsLimit)
        XCTAssertEqual(package.creator, creator)
        XCTAssertEqual(package.packageNumber, packageNumber)
        XCTAssertEqual(package.items, items)
    }

    func testAddItem() {
        let book = item
        package.addItem(item: book)
        XCTAssertTrue(package.items.contains(book))
        XCTAssertEqual(package.items.count, 1)
    }

    func testDeleteItem() {
        let book = item
        package.addItem(item: book)
        package.removeItem(item: book)
        XCTAssertTrue(package.items.isEmpty)
    }

    func testEquivalence() {
        let packageCopy = Package(creator: creator, creatorAvatar: .blue,
                                  packageNumber: packageNumber, items: items, itemsLimit: itemsLimit)
        XCTAssertTrue(packageCopy == package)
        let packageCopyWithDifferentSequence = Package(creator: creator, creatorAvatar: .blue,
                                                       packageNumber: packageNumber,
                                                       items: items.reversed(), itemsLimit: itemsLimit)
        XCTAssertTrue(packageCopyWithDifferentSequence == package)
    }
}
