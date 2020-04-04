//
//  ToyCarWheelTests.swift
//  RelentlessTests
//
//  Created by Chow Yi Yin on 28/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class ToyCarWheelTests: XCTestCase {
    let shape = Shape.triangle
    var wheel: ToyCarWheel!

    override func setUp() {
        super.setUp()
        wheel = ToyCarWheel(shape: shape)
    }

    func testInit() {
        let wheel = ToyCarWheel(shape: shape)
        XCTAssertEqual(wheel.shape, shape)
    }

    func testComparison() {
        let wheelWithSmallerShape = ToyCarWheel(shape: Shape.circle)
        let wheelWithBiggerShape = ToyCarWheel(shape: Shape.square)
        let magazine = Magazine(name: "")
        XCTAssertTrue(wheelWithSmallerShape < wheel)
        XCTAssertTrue(wheel < wheelWithBiggerShape)
        XCTAssertTrue(magazine < wheel)
    }

    func testEquals() {
        XCTAssertTrue(wheel.equals(other: wheel))

        let copyOfWheel: Item = ToyCarWheel(shape: shape)
        XCTAssertTrue(wheel.equals(other: copyOfWheel))

        let otherItem = Magazine(name: "")
        XCTAssertFalse(wheel.equals(other: otherItem))

    }

    func testToString() {
        let wheel: Item = ToyCarWheel(shape: shape)
        let string = wheel.toString()
        XCTAssertEqual(string, ToyCarWheel.toyCarWheelHeader + shape.toString())
    }
}
