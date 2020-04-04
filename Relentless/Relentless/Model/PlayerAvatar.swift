//
//  PlayerAvatar.swift
//  Relentless
//
//  Created by Liu Zechu on 29/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

enum PlayerAvatar: String {
    // TODO: rename later
    case red, yellow, green, cyan, blue, purple

    static func getPreviousAvatar(avatar: PlayerAvatar) -> PlayerAvatar {
        switch avatar {
        case .red:
            return .purple
        case .yellow:
            return .red
        case .green:
            return .yellow
        case .cyan:
            return .green
        case .blue:
            return .cyan
        case .purple:
            return .blue
        }
    }

    static func getNextAvatar(avatar: PlayerAvatar) -> PlayerAvatar {
        switch avatar {
        case .red:
            return .yellow
        case .yellow:
            return .green
        case .green:
            return .cyan
        case .cyan:
            return .blue
        case .blue:
            return .purple
        case .purple:
            return .red
        }
    }
}
