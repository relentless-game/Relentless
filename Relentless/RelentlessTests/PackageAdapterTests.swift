//
//  PackageAdapterTests.swift
//  RelentlessTests
//
//  Created by Liu Zechu on 22/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class PackageAdapterTests: XCTestCase {

    let itemsLimit = 5

    let imageRepresentation = ImageRepresentation(imageStrings: ["placeholder"])
    
    func testEncodePackageThenDecodePackage_1() {
        let item1 = TitledItem(name: "1", category: Category(name: "book"),
                               isInventoryItem: true, isOrderItem: true,
                               imageRepresentation: imageRepresentation)
        let item2 = TitledItem(name: "2", category: Category(name: "book"),
                               isInventoryItem: true, isOrderItem: true,
                               imageRepresentation: imageRepresentation)
        let itemsForPackage1 = [item1, item2]
        
        let package1 = Package(creator: "creator1", creatorAvatar: .blue,
                               packageNumber: 1, items: itemsForPackage1, itemsLimit: itemsLimit)
        
        let encodeString = PackageAdapter.encodePackage(package: package1)!
        let decodedPackage = PackageAdapter.decodePackage(from: encodeString)!
        
        XCTAssertEqual(decodedPackage, package1)
    }

    func testEncodePackageThenDecodePackage_2() {
        let item3 = TitledItem(name: "3", category: Category(name: "book"),
                               isInventoryItem: true, isOrderItem: true,
                               imageRepresentation: imageRepresentation)
        let item4 = StatefulItem(category: Category(name: "wheel"), stateIdentifier: 1,
                                 isInventoryItem: true, isOrderItem: false,
                                 imageRepresentation: imageRepresentation)
        let item5 = StatefulItem(category: Category(name: "wheel"), stateIdentifier: 2,
                                 isInventoryItem: true, isOrderItem: false,
                                 imageRepresentation: imageRepresentation)
        let itemsForPackage2 = [item3, item4, item5]
        
        let package2 = Package(creator: "creator2", creatorAvatar: .blue,
                               packageNumber: 2, items: itemsForPackage2, itemsLimit: itemsLimit)
        
        let encodeString = PackageAdapter.encodePackage(package: package2)!
        let decodedPackage = PackageAdapter.decodePackage(from: encodeString)!
        
        XCTAssertEqual(decodedPackage, package2)
    }
    
}
