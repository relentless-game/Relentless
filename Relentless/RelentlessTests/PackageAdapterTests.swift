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
    
    func testEncodePackageThenDecodePackage_1() {
        let item1 = Book(name: "book1")
        let item2 = Book(name: "book2")
        let item3 = Book(name: "book3")
        let itemsForPackage1 = [item1, item2, item3]
        
        let package1 = Package(creator: "creator1", creatorAvatar: .blue,
                               packageNumber: 1, items: itemsForPackage1, itemsLimit: itemsLimit)
        
        let encodeString = PackageAdapter.encodePackage(package: package1)!
        let decodedPackage = PackageAdapter.decodePackage(from: encodeString)!
        
        XCTAssertEqual(decodedPackage, package1)
    }
    
    func testEncodePackageThenDecodePackage_2() {
        let item4 = Book(name: "book4")
        let item5 = Magazine(name: "mag1")
        let item6 = Magazine(name: "mag2")
        let item7 = Magazine(name: "mag3")
        let itemsForPackage2 = [item4, item5, item6, item7]
        
        let package2 = Package(creator: "creator2", creatorAvatar: .blue,
                               packageNumber: 2, items: itemsForPackage2, itemsLimit: itemsLimit)
        
        let encodeString = PackageAdapter.encodePackage(package: package2)!
        let decodedPackage = PackageAdapter.decodePackage(from: encodeString)!
        
        XCTAssertEqual(decodedPackage, package2)
    }
    
}
