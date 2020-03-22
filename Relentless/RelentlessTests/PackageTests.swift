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
    var package: Package!

    override func setUp() {
        super.setUp()
        package = Package(creator: creator, packageNumber: packageNumber, items: items)
    }

    func testInit() {
        let package = Package(creator: creator, packageNumber: packageNumber, items: items)
        XCTAssertEqual(package.creator, creator)
        XCTAssertEqual(package.packageNumber, packageNumber)
        XCTAssertEqual(package.items, items)
    }

    func testAddItem() {
        let book = Book(name: "Book")
        package.addItem(item: book)
        XCTAssertTrue(package.items.contains(book))
        XCTAssertEqual(package.items.count, 1)
    }

    func testDeleteItem() {
        let book = Book(name: "Book")
        package.addItem(item: book)
        package.removeItem(item: book)
        XCTAssertTrue(package.items.isEmpty)
    }

    func testEquivalence() {
        let packageCopy = Package(creator: creator, packageNumber: packageNumber, items: items)
        XCTAssertTrue(packageCopy == package)
        let packageCopyWithDifferentSequence = Package(creator: creator, packageNumber: packageNumber, items: items.reversed())
        XCTAssertTrue(packageCopyWithDifferentSequence == package)
    }
}
