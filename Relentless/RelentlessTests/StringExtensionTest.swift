//
//  StringExtensionTest.swift
//  RelentlessTests
//
//  Created by Yi Wai Chow on 20/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class StringExtensionTest: XCTestCase {

    func test_invalidExpression_returnNil() {
        let invalidExpressionString = "+"
        XCTAssertNil(invalidExpressionString.expression)

        let invalidExpressionStringTwo = "2 *"
        XCTAssertNil(invalidExpressionStringTwo.expression)
    }

    func test_validExpression_notNil() {
        let validExpressionString = "2 + 3"
        XCTAssertNotNil(validExpressionString.expression)

        let validExpressionStringTwo = "(1.5 * 3 + 2) - 8"
        XCTAssertNotNil(validExpressionStringTwo.expression)
    }

}
