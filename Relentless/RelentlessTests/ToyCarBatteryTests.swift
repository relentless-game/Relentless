//
//  ToyCarBatteryTests.swift
//  RelentlessTests
//
//  Created by Chow Yi Yin on 28/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class ToyCarBatteryTests: XCTestCase {
    let label = Label.aa
    var battery: ToyCarBattery!

    override func setUp() {
        super.setUp()
        battery = ToyCarBattery(label: label)
    }

    func testInit() {
        let battery = ToyCarBattery(label: label)
        XCTAssertEqual(battery.label, label)
    }

    func testComparison() {
        let batteryWithSmallerLabel = ToyCarBattery(label: Label.d)
        let batteryWithBiggerLabel = ToyCarBattery(label: Label.pp3)
        let magazine = Magazine(name: String(label.toString().dropFirst()))
        XCTAssertTrue(batteryWithSmallerLabel < battery)
        XCTAssertTrue(battery < batteryWithBiggerLabel)
        XCTAssertTrue(magazine < battery) // battery has category toy car > magazine
    }

    func testEquals() {
        XCTAssertTrue(battery.equals(other: battery))

        let copyOfBattery: Item = ToyCarBattery(label: label)
        XCTAssertTrue(battery.equals(other: copyOfBattery))

        let otherItem = Magazine(name: "")
        XCTAssertFalse(copyOfBattery.equals(other: otherItem))

    }

    func testToString() {
        let battery: Item = ToyCarBattery(label: label)
        let string = battery.toString()
        XCTAssertEqual(string, ToyCarBattery.toyCarBatteryHeader + label.rawValue)
    }
}
