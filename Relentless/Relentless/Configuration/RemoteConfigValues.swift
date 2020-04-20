//
//  RemoteConfigValues.swift
//  Relentless
//
//  Created by Yi Wai Chow on 20/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

class RemoteConfigValues: ConfigValues {

    var remoteConfig: RemoteConfig?

    init(remoteConfig: RemoteConfig) {
        self.remoteConfig = remoteConfig
    }

    func getString(for key: String) -> String? {
        remoteConfig?[key].stringValue
    }

    func getNumber(for key: String) -> NSNumber? {
        remoteConfig?[key].numberValue
    }

}
