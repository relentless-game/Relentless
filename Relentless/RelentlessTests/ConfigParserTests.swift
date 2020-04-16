//
//  ConfigParserTests.swift
//  RelentlessTests
//
//  Created by Liu Zechu on 12/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class ConfigParserTests: XCTestCase {

    func testGetPlist() throws {
        let parser = ConfigParser()
        let dict = parser.getPlist(from: "GameConfig")
        parser.getStatefulItems()
        print(dict!)
    }
    
    func testPermuteParts() throws {
        let parser = ConfigParser()
        
        let category1 = Category(name: "book")
        let category2 = Category(name: "wheel")

        let item1 = TitledItem(name: "1", category: category1,
                               isInventoryItem: true, isOrderItem: true,
                               imageString: "placeholder")
        let item2 = TitledItem(name: "2", category: category1,
                               isInventoryItem: true, isOrderItem: true,
                               imageString: "placeholder")
        let item3 = TitledItem(name: "3", category: category1,
                               isInventoryItem: true, isOrderItem: true,
                               imageString: "placeholder")
        let item4 = StatefulItem(category: category2, stateIdentifier: 1,
                                 isInventoryItem: true, isOrderItem: false,
                                 imageString: "placeholder")
        let item5 = StatefulItem(category: category2, stateIdentifier: 2,
                                 isInventoryItem: true, isOrderItem: false,
                                 imageString: "placeholder")
        
        let availableParts = [[item1, item2, item3], [item4, item5]]
        
        let result = parser.permuteParts(availableParts: availableParts, currentIndex: 0)
        print(result.flatMap{ $0 }.map { $0.toString() })
    }

}
