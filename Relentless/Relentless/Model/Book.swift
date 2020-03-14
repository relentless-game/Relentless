//
//  Book.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

struct Book: Item {
    var name: String

    init(name: String) {
        self.name = name
    }
}
