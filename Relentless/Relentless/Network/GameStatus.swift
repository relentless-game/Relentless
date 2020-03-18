//
//  GameStatus.swift
//  Relentless
//
//  Created by Liu Zechu on 15/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// This struct represents the current status of the game, and it is shared across
/// the network so that players can be notified when the game status changes.
struct GameStatus: Codable {
    var isGamePlaying: Bool
    var isRoundPlaying: Bool
    var isGameEndedPrematurely: Bool
    var currentRound: Int
    
    init(isGamePlaying: Bool, isRoundPlaying: Bool, isGameEndedPrematurely: Bool, currentRound: Int) {
        self.isGamePlaying = isGamePlaying
        self.isRoundPlaying = isRoundPlaying
        self.isGameEndedPrematurely = isGameEndedPrematurely
        self.currentRound = currentRound
    }
    
    func encodeToString() -> String? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            let string = String(data: data, encoding: .utf8)
            return string
        } catch {
            return nil
        }
    }
    
    static func decodeFromString(string: String) -> GameStatus? {
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            let gameStatus = try decoder.decode(GameStatus.self, from: data)
            return gameStatus
        } catch {
            return nil
        }
    }
    
//    func encodeToDictionary() -> [String: Any] {
//        let result = [
//            "isGamePlaying": isGamePlaying,
//            "isRoundPlaying": isRoundPlaying,
//            "currentRound": currentRound
//        ] as [String: Any]
//
//        return result
//    }
//
//    static func decodeFromDictionary(dict: [String: Any]) -> GameStatus? {
//        guard let isGamePlaying = dict["isGamePlaying"] as? Bool,
//            let isRoundPlaying = dict["isRoundPlaying"] as? Bool,
//            let currentRound = dict["currentRound"] as? Int else {
//            return nil
//        }
//
//        let result = GameStatus(isGamePlaying: isGamePlaying, isRoundPlaying: isRoundPlaying,
//                                currentRound: currentRound)
//        return result
//    }
    
}
