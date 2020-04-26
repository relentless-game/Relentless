//
//  PlayerAvatar.swift
//  Relentless
//
//  Created by Liu Zechu on 29/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

/// Represents a player's avatar in the game.
enum PlayerAvatar: String, Codable, CaseIterable {
    
    case red
    case yellow
    case green
    case cyan
    case blue
    case purple

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PlayerAvatarKeys.self)
        let rawValue = try container.decode(String.self, forKey: .playerAvatar)
        switch rawValue {
        case PlayerAvatar.red.rawValue:
            self = .red
        case PlayerAvatar.yellow.rawValue:
            self = .yellow
        case PlayerAvatar.green.rawValue:
            self = .green
        case PlayerAvatar.cyan.rawValue:
            self = .cyan
        case PlayerAvatar.blue.rawValue:
            self = .blue
        case PlayerAvatar.purple.rawValue:
            self = .purple
        default:
            throw PlayerAvatarError.unknownValue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PlayerAvatarKeys.self)
        switch self {
        case .red:
            try container.encode(PlayerAvatar.red.rawValue, forKey: .playerAvatar)
        case .yellow:
            try container.encode(PlayerAvatar.yellow.rawValue, forKey: .playerAvatar)
        case .green:
            try container.encode(PlayerAvatar.green.rawValue, forKey: .playerAvatar)
        case .cyan:
            try container.encode(PlayerAvatar.cyan.rawValue, forKey: .playerAvatar)
        case .blue:
            try container.encode(PlayerAvatar.blue.rawValue, forKey: .playerAvatar)
        case .purple:
            try container.encode(PlayerAvatar.purple.rawValue, forKey: .playerAvatar)
        }
    }

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

    func toString() -> String {
        self.rawValue
    }
}

enum PlayerAvatarKeys: CodingKey {
    case playerAvatar
}

enum PlayerAvatarError: Error {
    case unknownValue
}
