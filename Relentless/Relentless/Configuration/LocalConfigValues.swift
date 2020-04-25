//
//  DemoConfigValues.swift
//  Relentless
//
//  Created by Yi Wai Chow on 24/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class LocalConfigValues: ConfigValues, Codable {

    var valuesDict: [String: String?]?

    init(dict: [String: String?]?) {
        self.valuesDict = dict
    }

    init(filePath: String) {
        do {
            try valuesDict = getPlist(from: filePath)
        } catch {
            valuesDict = [:]
            assertionFailure("Loading Plist failed.")
        }
    }

    func getString(for key: String) -> String? {
        valuesDict?[key] as? String
    }

    func getNumber<T>(for key: String) -> T? {
        valuesDict?[key] as? T
    }

    private func removeValue(key: String) {
        valuesDict?[key] = nil
    }

    private func getPlist(from fileName: String) throws -> [String: String?]? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path) {
            if let contents = (try? PropertyListSerialization.propertyList(from: xml,
                                                                           options: .mutableContainersAndLeaves,
                                                                           format: nil)) as? [String: String?] {
                return contents
            } else {
                throw LocalConfigValuesError.plistLoadingError
            }
        }
        throw LocalConfigValuesError.plistLoadingError
    }

    func encodeToString() -> String? {
       let encoder = JSONEncoder()
       do {
           let data = try encoder.encode(self)
           let string = String(data: data, encoding: .utf8)
           return string
       } catch {
           return nil
       }
   }

    static func decodeFromString(string: String) -> LocalConfigValues? {
        guard let data = string.data(using: .utf8) else {
            return nil
        }

        let decoder = JSONDecoder()
        do {
            let localConfigValues = try decoder.decode(LocalConfigValues.self, from: data)
            return localConfigValues
        } catch {
            return nil
        }
    }

}

enum LocalConfigValuesError: Error {
    case plistLoadingError
}
