//
//  ConfigNetwork.swift
//  Relentless
//
//  Created by Yi Wai Chow on 12/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol ConfigNetwork {

    func fetchGameHostParameters() -> GameHostParameters?

    func fetchLocalConfigValues() -> LocalConfigValues?

}
