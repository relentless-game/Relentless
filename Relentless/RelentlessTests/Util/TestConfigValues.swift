//
//  RemoteConfigStub.swift
//  RelentlessTests
//
//  Created by Yi Wai Chow on 20/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
@testable import Relentless
/// Util class that gets values from local plist meant for testing purposes instead of from remote config
class TestConfigValues: ConfigValues {

    var valuesDict: NSDictionary?

    init() {
        do {
            try valuesDict = getPlist(from: "TestGameParameters")
        } catch {
            valuesDict = [:]
            assertionFailure("Loading Plist failed.")
        }
    }

    func getString(for key: String) -> String? {
        valuesDict?.value(forKey: key) as? String
    }

    func getNumber(for key: String) -> NSNumber? {
        valuesDict?.value(forKey: key) as? NSNumber
    }

    private func getPlist(from fileName: String) throws -> NSDictionary {
        if let path = Bundle.main.path(forResource: fileName, ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path) {
            if let contents = (try? PropertyListSerialization.propertyList(from: xml,
                                                                           options: .mutableContainersAndLeaves,
                                                                           format: nil)) as? NSDictionary {
                return contents
            } else {
                throw TestConfigValuesError.plistLoadingError
            }
        }
        throw TestConfigValuesError.plistLoadingError
    }

}

enum TestConfigValuesError: Error {
    case plistLoadingError
}
