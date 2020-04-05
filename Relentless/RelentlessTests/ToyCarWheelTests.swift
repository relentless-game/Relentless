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
    let shape = Shape.circle
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
//        let wheelWithSmallerRadius = ToyCarWheel(radius: radius - 1)
//        let wheelWithBiggerRadius = ToyCarWheel(radius: radius + 1)
//        let magazine = Magazine(name: "")
//        XCTAssertTrue(wheelWithSmallerRadius < wheel)
//        XCTAssertTrue(wheel < wheelWithBiggerRadius)
//        XCTAssertTrue(magazine < wheel)
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
        XCTAssertEqual(string, ToyCarWheel.toyCarWheelHeader + shape.rawValue)
    }
}
