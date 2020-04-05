//
//  Event.swift
//  Relentless
//
//  Created by Yi Wai Chow on 4/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol Event {

    // Duration of event in seconds
    var duration: Int { get }

    func occur()

}
