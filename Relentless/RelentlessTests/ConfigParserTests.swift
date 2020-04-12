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

}
