//
//  GameParametersParserTest.swift
//  RelentlessTests
//
//  Created by Yi Wai Chow on 20/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import XCTest
@testable import Relentless

class GameParametersParserTest: XCTestCase {
    var gameParameters: GameParameters!

    override func setUp() {
        super.setUp()
        let configValues: ConfigValues = TestConfigValues()
        let parser = GameParametersParser(configValues: configValues)

        gameParameters = parser.parse()
    }

    func testParse_parameterValues() {
        let expectedNumOfHouses = 5
        let expectedDifficultyChange = 0.5
        let expectedHouseSatisfactionRange = 0.5...1
        let expectedDifficultyRange: ClosedRange<Double> = 1...10
        let expectedSatisfactionRange: ClosedRange<Double> = 0...100
        let expectedRoundTime = 240
        let expectedDailyExpense = 50
        let expectedSatisfactionToMoneyTranslation = 2
        let expectedSatisfactionRunOutPenalty: Double = 20
        let expectedSatisfactionUnitDecrease: Double = 0.416_666_66

        XCTAssertEqual(gameParameters.numOfHouses, expectedNumOfHouses)
        XCTAssertEqual(gameParameters.difficultyChange, expectedDifficultyChange)
        XCTAssertEqual(gameParameters.houseSatisfactionFactorRange, expectedHouseSatisfactionRange)
        XCTAssertEqual(gameParameters.difficultyRange, expectedDifficultyRange)
        XCTAssertEqual(gameParameters.satisfactionRange, expectedSatisfactionRange)
        XCTAssertEqual(gameParameters.roundTime, expectedRoundTime)
        XCTAssertEqual(gameParameters.dailyExpense, expectedDailyExpense)
        XCTAssertEqual(gameParameters.satisfactionToMoneyTranslation, expectedSatisfactionToMoneyTranslation)
        XCTAssertEqual(gameParameters.satisfactionRunOutPenalty, expectedSatisfactionRunOutPenalty)

        do {
            let satisfactionUnitDecrease = try XCTUnwrap(gameParameters.satisfactionUnitDecrease)
            XCTAssertEqual(satisfactionUnitDecrease, expectedSatisfactionUnitDecrease, accuracy: 0.000_000_01)
        } catch {
            XCTFail("Property should not be nil")
        }
    }

    func testParse_parameterExpression_packageSatisfactionChange() {
        let varDictCorrectPackage = [VariableNames.numOfDifferences: 2,
                                     VariableNames.numOfItems: 2,
                                     VariableNames.timeLeft: 5.0,
                                     VariableNames.totalTime: 10.0]
        let correctPackageExpression = gameParameters.correctPackageSatisfactionChangeExpression
        let expectedCorrectPackageValue = 14.5
        XCTAssertEqual(correctPackageExpression?(varDictCorrectPackage), expectedCorrectPackageValue)

        let varDictWrongPackage = [VariableNames.numOfDifferences: 2,
                                   VariableNames.numOfItems: 4,
                                   VariableNames.timeLeft: 5.0,
                                   VariableNames.totalTime: 10.0]

        let wrongPackageExpression = gameParameters.wrongPackageSatisfactionChangeExpression
        let expectedWrongPackageValue: Double = -13
        XCTAssertEqual(wrongPackageExpression?(varDictWrongPackage), expectedWrongPackageValue)    }

    func testParse_emptyConfigKeys_returnNil() {
        let emptyConfigValues: ConfigValues = TestConfigValues(empty: true)
        let parser = GameParametersParser(configValues: emptyConfigValues)

        gameParameters = parser.parse()
        XCTAssertNil(gameParameters)
    }

    func testParse_missingValues_returnNil() {
        let incompleteConfigValues: ConfigValues = TestConfigValues(without: ConfigKeys.numOfHouses)
        let parser = GameParametersParser(configValues: incompleteConfigValues)

        gameParameters = parser.parse()
        XCTAssertNil(gameParameters)
    }

}
