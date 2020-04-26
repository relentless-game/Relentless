//
//  ConfigValues.swift
//  Relentless
//
//  Created by Yi Wai Chow on 20/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// This represents utility methods to get a String or a Number
/// for game parameter configuration stored remotely or locally.
protocol ConfigValues {

    func getString(for key: String) -> String?

    func getNumber<T>(for key: String) -> T?
    
}
