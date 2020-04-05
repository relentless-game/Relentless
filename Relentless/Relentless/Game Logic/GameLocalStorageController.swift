//
//  GameLocalStorageController.swift
//  Relentless
//
//  Created by Chow Yi Yin on 3/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
protocol GameLocalStorageController {

    var localStorage: LocalStorage { get }

    func getExistingScores() throws -> [ScoreRecord]
    
}
