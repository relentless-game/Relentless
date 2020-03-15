//
//  BookTests.swift
//  RelentlessTests
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class BookTests: XCTestCase {
    let title = "Title"
    var book: Book!
    override func setUp() {
        super.setUp()
        book = Book(name: title)
    }

    func testInit() {
        let book = Book(name: title)
        XCTAssertEqual(book.name, title)
    }

    func testComparison() {
        let bookWithSmallerName = Book(name: String(title.dropFirst()))
        let bookWithBiggerName = Book(name: title.uppercased())
        XCTAssertTrue(bookWithSmallerName < book)
        XCTAssertTrue(book < bookWithBiggerName)
    }
    func testEquals(other: Item) {
        XCTAssertTrue(book.equals(other: book))

        let copyOfBook = Book(name: title)
        XCTAssertTrue(book.equals(other: copyOfBook))

        let otherItem = Magazine(name: title)
        XCTAssertFalse(book.equals(other: otherItem))
    }

}
