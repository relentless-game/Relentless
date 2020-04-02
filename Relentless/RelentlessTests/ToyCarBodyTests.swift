//
//  ToyCarBodyTests.swift
//  RelentlessTests
//
//  Created by Chow Yi Yin on 28/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class ToyCarBodyTests: XCTestCase {
    let colour = Colour.green
    var body: ToyCarBody!

    override func setUp() {
        super.setUp()
        body = ToyCarBody(colour: colour)
    }

    func testInit() {
        let body = ToyCarBody(colour: colour)
        XCTAssertEqual(body.colour, colour)
    }

    func testComparison() {
        let bodyWithSmallerColourRawValue = ToyCarBody(colour: Colour.blue)
        let bodyWithLargerColourRawValue = ToyCarBody(colour: Colour.red)
        let magazine = Magazine(name: "")
        XCTAssertTrue(bodyWithSmallerColourRawValue < body)
        XCTAssertTrue(body < bodyWithLargerColourRawValue)
        XCTAssertTrue(magazine < body)
    }

    func testEquals() {
        XCTAssertTrue(body.equals(other: body))

        let copyOfBody: Item = ToyCarBody(colour: colour)
        XCTAssertTrue(body.equals(other: copyOfBody))

        let otherItem = Magazine(name: "")
        XCTAssertFalse(body.equals(other: otherItem))

    }

    func testToString() {
        let body: Item = ToyCarBody(colour: colour)
        let string = body.toString()
        XCTAssertEqual(string, ToyCarBody.toyCarBodyHeader + colour.toString())
    }
}
