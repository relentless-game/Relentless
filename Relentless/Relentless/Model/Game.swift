//
//  Game.swift
//  Relentless
//
//  Created by Chow Yi Yin on 14/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class Game {
    /// user information
    var user: Player
    var otherPlayers: [Player]

    /// game information
    var packages = [Package]()
    var houses = [House]()
    var cumulativePackageNumber = 0

    init(user: Player, otherPlayers: [Player]) {
        self.user = user
        self.otherPlayers = otherPlayers
    }

    func addPackage() {
        let emptyPackage = Package(creator: user.userName, packageNumber: cumulativePackageNumber, items: [Item]())
        packages.append(emptyPackage)
    }

    func deletePackage(package: Package) {
        guard let indexOfPackage = packages.firstIndex(of: package) else {
            return
        }
        packages.remove(at: indexOfPackage)
    }

}
