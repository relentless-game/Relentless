//
//  TestItemSpecificationsParser.swift
//  RelentlessTests
//
//  Created by Liu Zechu on 21/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

// A util class to get the test plist for GameConfig for testing
class TestItemSpecificationsParser {
    
    static func getPlist(from fileName: String) throws -> NSDictionary {
        if let path = Bundle.main.path(forResource: fileName, ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path) {
            if let contents = (try? PropertyListSerialization.propertyList(from: xml,
                                                                           options: .mutableContainersAndLeaves,
                                                                           format: nil)) as? NSDictionary {
                return contents
            } else {
                throw TestItemSpecsParserError.plistLoadingError
            }
        }
        throw TestItemSpecsParserError.plistLoadingError
    }
    
}

enum TestItemSpecsParserError: Error {
    case plistLoadingError
}
