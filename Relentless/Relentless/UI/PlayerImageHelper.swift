//
//  PlayerImageHelper.swift
//  Relentless
//
//  Created by Yanch on 4/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class PlayerImageHelper {
    private static let redAvatar = UIImage(named: "avatar_red.png")
    private static let yellowAvatar = UIImage(named: "avatar_yellow.png")
    private static let greenAvatar = UIImage(named: "avatar_green.png")
    private static let cyanAvatar = UIImage(named: "avatar_cyan.png")
    private static let blueAvatar = UIImage(named: "avatar_blue.png")
    private static let purpleAvatar = UIImage(named: "avatar_purple.png")
    private static let redPackage = UIImage(named: "package_red.png")
    private static let yellowPackage = UIImage(named: "package_yellow.png")
    private static let greenPackage = UIImage(named: "package_green.png")
    private static let cyanPackage = UIImage(named: "package_cyan.png")
    private static let bluePackage = UIImage(named: "package_blue.png")
    private static let purplePackage = UIImage(named: "package_purple.png")
    private static let redAdd = UIImage(named: "add_red.png")
    private static let yellowAdd = UIImage(named: "add_yellow.png")
    private static let greenAdd = UIImage(named: "add_green.png")
    private static let cyanAdd = UIImage(named: "add_cyan.png")
    private static let blueAdd = UIImage(named: "add_blue.png")
    private static let purpleAdd = UIImage(named: "add_purple.png")

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

    static func getPackageImage(for avatar: PlayerAvatar) -> UIImage? {
        switch avatar {
        case .red:
            return redPackage
        case .yellow:
            return yellowPackage
        case .green:
            return greenPackage
        case .cyan:
            return cyanPackage
        case .blue:
            return bluePackage
        case .purple:
            return purplePackage
        }
    }

    static func getAddImage(for avatar: PlayerAvatar) -> UIImage? {
        switch avatar {
        case .red:
            return redAdd
        case .yellow:
            return yellowAdd
        case .green:
            return greenAdd
        case .cyan:
            return cyanAdd
        case .blue:
            return blueAdd
        case .purple:
            return purpleAdd
        }
    }
}
