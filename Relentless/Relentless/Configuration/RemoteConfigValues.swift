//
//  RemoteConfigValues.swift
//  Relentless
//
//  Created by Yi Wai Chow on 20/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

/// This is the implementation class of the protocol `ConfigValues` for Remote Config.
/// It is a util class to get a String or Number from game parameter cofiguration stored remotely.
class RemoteConfigValues: ConfigValues {

    var remoteConfig: RemoteConfig?

    init(remoteConfig: RemoteConfig) {
        self.remoteConfig = remoteConfig
    }

    func getString(for key: String) -> String? {
        remoteConfig?[key].stringValue
    }

    func getNumber<T>(for key: String) -> T? {
        remoteConfig?[key].numberValue as? T
    }

    func convertToLocalConfig() -> LocalConfigValues? {
        var remoteDict = [String: String?]()
        if let remoteKeys = remoteConfig?.allKeys(from: .remote) {
            remoteDict = extractValues(keys: remoteKeys)
        }

        var defaultDict = [String: String?]()
        if let defaultKeys = remoteConfig?.allKeys(from: .default) {
            defaultDict = extractValues(keys: defaultKeys)
        }

        remoteDict.merge(defaultDict) { current, _ in current }

        return LocalConfigValues(dict: remoteDict)
    }

    private func extractValues(keys: [String]) -> [String: String?] {
        var dict = [String: String?]()
        for key in keys {
            if let stringValue = getString(for: key) {
                dict[key] = stringValue
            } else if let numberValue: Double = getNumber(for: key) {
                dict[key] = String(format: "%f", numberValue)
            }
        }
        return dict
    }
}
