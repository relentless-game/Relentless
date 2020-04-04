//
//  PlayerImageHelper.swift
//  Relentless
//
//  Created by Yanch on 4/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class PlayerImageHelper {
    static let redAvatar = UIImage(named: "avatar_red.png")
    static let yellowAvatar = UIImage(named: "avatar_yellow.png")
    static let greenAvatar = UIImage(named: "avatar_green.png")
    static let cyanAvatar = UIImage(named: "avatar_cyan.png")
    static let blueAvatar = UIImage(named: "avatar_blue.png")
    static let purpleAvatar = UIImage(named: "avatar_purple.png")

    static func getAvatarImage(for avatar: PlayerAvatar) -> UIImage? {
        switch avatar {
        case .red:
            return redAvatar
        case .yellow:
            return yellowAvatar
        case .green:
            return greenAvatar
        case .cyan:
            return cyanAvatar
        case .blue:
            return blueAvatar
        case .purple:
            return purpleAvatar
        }
    }
}
