//
//  ConfigValues.swift
//  Relentless
//
//  Created by Yi Wai Chow on 20/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol ConfigValues {

    func getString(for key: String) -> String?

    func getNumber<T>(for key: String) -> T?
    
}
