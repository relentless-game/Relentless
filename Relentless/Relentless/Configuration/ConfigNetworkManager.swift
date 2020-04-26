//
//  ConfigNetworkManager.swift
//  Relentless
//
//  Created by Yi Wai Chow on 12/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
import Firebase

class ConfigNetworkManager: ConfigNetwork {

    private static let sharedInstance = ConfigNetworkManager()

    var remoteConfig: RemoteConfig!

    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.setDefaults(fromPlist: "DefaultGameParameters")
        activateFetchedValues()
        fetchCloudValues()
    }

    static func getInstance() -> ConfigNetworkManager {
        sharedInstance
    }

    func fetchGameHostParameters() -> GameHostParameters? {
        let configValues = RemoteConfigValues(remoteConfig: remoteConfig)
        let parser = GameHostParametersParser(configValues: configValues)
        return parser.parse()
    }

    func fetchLocalConfigValues() -> LocalConfigValues? {
        let configValues = RemoteConfigValues(remoteConfig: remoteConfig)
        return configValues.convertToLocalConfig()
    }

    private func activateFetchedValues() {
        remoteConfig.activate(completionHandler: { error in
            if let error = error {
                print("[Remote Config] Fetched values not activated")
                print("Error: \(error.localizedDescription)")
                return
            }
            print("Fetched values activated")
        })
    }

    private func fetchCloudValues() {
        remoteConfig.fetch(completionHandler: { status, error -> Void in
          if status == .success {
            print("[Remote Config] Fetched")
          } else {
            print("[Remote Config] Not fetched")
            print("Error: \(error?.localizedDescription ?? "No error available.")")
          }
        })
    }

}
