//
//  ItemAssemblerTests.swift
//  RelentlessTests
//
//  Created by Chow Yi Yin on 21/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class ItemAssemblerTests: XCTestCase {
    let wheelCategory = Category(name: "wheel")
    let batteryCategory = Category(name: "battery")
    let toyCarCategory = Category(name: "toyCar")
    let imageRepresentation = ImageRepresentation(imageStrings: [""])

    var wheel: Item!
    var battery: Item!
    var parts: [Item]!
    var mapping: [[Relentless.Category]: Relentless.Category]!
    var imageRepresentationMapping = [Relentless.Category: ImageRepresentation]() // not tested here
    
    override func setUp() {
        super.setUp()
        wheel = StatefulItem(category: wheelCategory, stateIdentifier: 1,
                             isInventoryItem: true, isOrderItem: false,
                             imageRepresentation: imageRepresentation)
        battery = StatefulItem(category: batteryCategory, stateIdentifier: 1,
                               isInventoryItem: true, isOrderItem: false,
                               imageRepresentation: imageRepresentation)
        parts = [wheel, battery].sorted()
        mapping = [[wheelCategory, batteryCategory].sorted(): toyCarCategory]
    }

    func testAssembler_hasCorrectPartsToCreateItemThatExists() {
        do {
            var imageRepresentationMapping = [Relentless.Category: ImageRepresentation]()
            let partsImageStrings = [Relentless.Category: ImageRepresentation]()
            imageRepresentationMapping[toyCarCategory] =
                AssembledItemImageRepresentation(mainImageStrings: [""],
                                                 partsImageStrings: partsImageStrings)
            let assembledItem =
                try ItemAssembler.assembleItem(parts: parts,
                                               partsToAssembledItemCategoryMapping: mapping,
                                               imageRepresentationMapping: imageRepresentationMapping)
            XCTAssertEqual(assembledItem.parts, parts)
        } catch {
            XCTFail("Should not throw error")
        }
    }

    func testAssembler_tooManyParts_throws() {
        guard let wheel = wheel, let battery = battery else {
            XCTFail("Test set up went wrong... wheel and battery should not be nil")
            return
        }
        let wrongParts = [wheel, wheel, battery]
        XCTAssertThrowsError(try ItemAssembler.assembleItem(parts: wrongParts,
                                                            partsToAssembledItemCategoryMapping: mapping,
                                                            imageRepresentationMapping: imageRepresentationMapping))
    }

    func testAssembler_tooFewParts_throws() {
        guard let wheel = wheel else {
            XCTFail("Test set up went wrong... wheel should not be nil")
            return
        }
        let wrongParts = [wheel]
        XCTAssertThrowsError(try ItemAssembler.assembleItem(parts: wrongParts,
                                                            partsToAssembledItemCategoryMapping: mapping,
                                                            imageRepresentationMapping: imageRepresentationMapping))
    }

    func testAssembler_wrongParts_throws() {
        let toyCarCategory = Category(name: "toyCarBody")
        let toyCarBody = StatefulItem(category: toyCarCategory, stateIdentifier: 1,
                                      isInventoryItem: true, isOrderItem: false,
                                      imageRepresentation: imageRepresentation)
        let wrongParts = [toyCarBody]
        XCTAssertThrowsError(try ItemAssembler.assembleItem(parts: wrongParts,
                                                            partsToAssembledItemCategoryMapping: mapping,
                                                            imageRepresentationMapping: imageRepresentationMapping))
    }}
