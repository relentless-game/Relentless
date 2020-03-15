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
struct GameStatus {
    var isGamePlaying: Bool
    var isRoundPlaying: Bool
    var currentRound: Int
    
    init(isGamePlaying: Bool, isRoundPlaying: Bool, currentRound: Int) {
        self.isGamePlaying = isGamePlaying
        self.isRoundPlaying = isRoundPlaying
        self.currentRound = currentRound
    }
    
    func encodeToDictionary() -> [String: Any] {
        let result = [
            "isGamePlaying": isGamePlaying,
            "isRoundPlaying": isRoundPlaying,
            "currentRound": currentRound
        ] as [String: Any]
        
        return result
    }
    
    static func decodeFromDictionary(dict: [String: Any]) -> GameStatus? {
        guard let isGamePlaying = dict["isGamePlaying"] as? Bool,
            let isRoundPlaying = dict["isRoundPlaying"] as? Bool,
            let currentRound = dict["currentRound"] as? Int else {
            return nil
        }
        
        let result = GameStatus(isGamePlaying: isGamePlaying, isRoundPlaying: isRoundPlaying,
                                currentRound: currentRound)
        return result
    }
    
}
