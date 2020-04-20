//
//  GameHostParametersParserTest.swift
//  RelentlessTests
//
//  Created by Yi Wai Chow on 20/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class GameHostParametersParserTest: XCTestCase {
    var gameHostParameters: GameHostParameters!
    let configValues: ConfigValues = TestConfigValues()

    override func setUp() {
        super.setUp()
        let parser = GameHostParametersParser(configValues: configValues)

        gameHostParameters = parser.parse()
    }

    func testParse_nonHostParameterValues() {
        let nonHostParser = GameParametersParser(configValues: configValues)
        let nonHostParameters = nonHostParser.parse()

        XCTAssertEqual(gameHostParameters.numOfHouses, nonHostParameters?.numOfHouses)
        XCTAssertEqual(gameHostParameters.difficultyChange, nonHostParameters?.difficultyChange)
        XCTAssertEqual(gameHostParameters.houseSatisfactionFactorRange, nonHostParameters?.houseSatisfactionFactorRange)
        XCTAssertEqual(gameHostParameters.numOfPlayersRange, nonHostParameters?.numOfPlayersRange)
        XCTAssertEqual(gameHostParameters.difficultyRange, nonHostParameters?.difficultyRange)
        XCTAssertEqual(gameHostParameters.satisfactionRange, nonHostParameters?.satisfactionRange)
        XCTAssertEqual(gameHostParameters.roundTime, nonHostParameters?.roundTime)
        XCTAssertEqual(gameHostParameters.dailyExpense, nonHostParameters?.dailyExpense)
        XCTAssertEqual(gameHostParameters.satisfactionToMoneyTranslation,
                       nonHostParameters?.satisfactionToMoneyTranslation)
        XCTAssertEqual(gameHostParameters.satisfactionRunOutPenalty, nonHostParameters?.satisfactionRunOutPenalty)
        XCTAssertEqual(gameHostParameters.satisfactionUnitDecrease, nonHostParameters?.satisfactionUnitDecrease)
    }

    func testParse_parameterExpression_packageSatisfactionChange() {
        let varDict = [VariableNames.numOfCorrectItems: 2,
                       VariableNames.timeLeft: 5.0,
                       VariableNames.totalTime: 10.0]
        let correctPackageExpression = gameHostParameters.correctPackageSatisfactionChangeExpression
        let expectedCorrectPackageValue = 14.5
        XCTAssertEqual(correctPackageExpression?(varDict), expectedCorrectPackageValue)

        let wrongPackageExpression = gameHostParameters.wrongPackageSatisfactionChangeExpression
        let expectedWrongPackageValue = -10.5
        XCTAssertEqual(wrongPackageExpression?(varDict), expectedWrongPackageValue)
    }

    func testParse_hostValues() {
        gameHostParameters.difficultyLevel = 3.0

        let expectedTimeForEachItem = 70
        let expectedNumOfCategories = 2
        let expectedNumOfGroupsPerCategory = 2
        let expectedMaxNumOfItemsPerOrder = 2
        let expectedNumOfOrdersPerPlayer = 2
        let expectedProbOfSelectingOwnItem = 0.25
        let expectedProbOfHavingPackageLimit = 0.06
        let expectedProbOfEvent = 0.25

        XCTAssertEqual(gameHostParameters.timeForEachItem, expectedTimeForEachItem)
        XCTAssertEqual(gameHostParameters.numOfCategories, expectedNumOfCategories)
        XCTAssertEqual(gameHostParameters.numOfGroupsPerCategory, expectedNumOfGroupsPerCategory)
        XCTAssertEqual(gameHostParameters.maxNumOfItemsPerOrder, expectedMaxNumOfItemsPerOrder)
        XCTAssertEqual(gameHostParameters.numOfOrdersPerPlayer, expectedNumOfOrdersPerPlayer)
        XCTAssertEqual(gameHostParameters.probOfSelectingOwnItem, expectedProbOfSelectingOwnItem)
        XCTAssertEqual(gameHostParameters.probOfHavingPackageLimit, expectedProbOfHavingPackageLimit)
        XCTAssertEqual(gameHostParameters.probOfEvent, expectedProbOfEvent)
    }
}
