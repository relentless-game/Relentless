//
//  GameCategoryGenerator.swift
//  Relentless
//
//  Created by Yi Wai Chow on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// Generates categories by choosing from the currently available categories.
protocol GameCategoryGenerator {

    func generateCategories() -> [Category]

}
