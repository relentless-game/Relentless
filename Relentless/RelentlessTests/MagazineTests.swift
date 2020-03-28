//
//  MagazineTests.swift
//  RelentlessTests
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class MagazineTests: XCTestCase {
    let title = "Title"
    var magazine: Magazine!
    override func setUp() {
        super.setUp()
        magazine = Magazine(name: title)
    }

    func testInit() {
        let magazine = Magazine(name: title)
        XCTAssertEqual(magazine.name, title)
    }

    func testComparison() {
        let magazineWithSmallerName = Magazine(name: String(title.dropFirst()))
        let magazineWithBiggerName = Magazine(name: title.uppercased())
        let book = Book(name: String(title.dropFirst()))
        XCTAssertTrue(magazineWithSmallerName < magazine)
        XCTAssertTrue(magazine < magazineWithBiggerName)
        XCTAssertTrue(book < magazine)
    }

    func testEquals(other: Item) {
        XCTAssertTrue(magazine.equals(other: magazine))

        let copyOfMagazine = Magazine(name: title)
        XCTAssertTrue(magazine.equals(other: copyOfMagazine))

        let otherItem = Book(name: title)
        XCTAssertFalse(magazine.equals(other: otherItem))
    }

}
