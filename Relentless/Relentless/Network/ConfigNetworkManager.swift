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

    static let sharedInstance = ConfigNetworkManager()

    var remoteConfig: RemoteConfig!

    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.setDefaults(fromPlist: "DefaultList")
        activateFetchedValues()
        fetchCloudValues()
    }

    func fetchGameParameters(isHost: Bool) -> GameParameters? {
        let parser: GameParametersParser
        if isHost {
            parser = GameHostParametersParser(remoteConfig: remoteConfig)
        } else {
            parser = GameParametersParser(remoteConfig: remoteConfig)
        }
        return parser.parse()
    }

    private func activateFetchedValues() {
        remoteConfig.activate(completionHandler: { error in
            if let error = error {
                print("Fetched values not activated")
                print("Error: \(error.localizedDescription)")
            }
            print("Fetched values activated")
        })
    }

    private func fetchCloudValues() {
        remoteConfig.fetch(completionHandler: { status, error -> Void in
          if status == .success {
            print("Config fetched")
          } else {
            print("Config not fetched")
            print("Error: \(error?.localizedDescription ?? "No error available.")")
          }
        })
    }

}
