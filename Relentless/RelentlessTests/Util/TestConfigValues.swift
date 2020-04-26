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
class TestConfigValues: LocalConfigValues {

    let filePath = "TestGameParameters"

    init() {
        super.init(filePath: filePath)
    }

    convenience init(empty: Bool) {
        self.init()
        if empty {
            valuesDict = [String: String?]()
        } 
    }

    convenience init(without key: String) {
        self.init()
        removeValue(key: key)
    }

    private func removeValue(key: String) {
        valuesDict?[key] = nil
    }
}
