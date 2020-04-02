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
    let radius = 2.0
    var wheel: ToyCarWheel!

    override func setUp() {
        super.setUp()
        wheel = ToyCarWheel(radius: radius)
    }

    func testInit() {
        let wheel = ToyCarWheel(radius: radius)
        XCTAssertEqual(wheel.radius, radius)
    }

    func testComparison() {
        let wheelWithSmallerRadius = ToyCarWheel(radius: radius - 1)
        let wheelWithBiggerRadius = ToyCarWheel(radius: radius + 1)
        let magazine = Magazine(name: "")
        XCTAssertTrue(wheelWithSmallerRadius < wheel)
        XCTAssertTrue(wheel < wheelWithBiggerRadius)
        XCTAssertTrue(magazine < wheel)
    }

    func testEquals() {
        XCTAssertTrue(wheel.equals(other: wheel))

        let copyOfWheel: Item = ToyCarWheel(radius: radius)
        XCTAssertTrue(wheel.equals(other: copyOfWheel))

        let otherItem = Magazine(name: "")
        XCTAssertFalse(wheel.equals(other: otherItem))

    }

    func testToString() {
        let wheel: Item = ToyCarWheel(radius: radius)
        let string = wheel.toString()
        XCTAssertEqual(string, ToyCarWheel.toyCarWheelHeader + String(radius))
    }
}
