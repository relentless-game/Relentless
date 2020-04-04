//
//  ScoreRecord.swift
//  Relentless
//
//  Created by Chow Yi Yin on 3/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
class ScoreRecord: Codable {
    let score: Int
    let userNamesOfPlayers: [String]

    init(score: Int, userNamesOfPlayers: [String]) {
        self.score = score
        self.userNamesOfPlayers = userNamesOfPlayers
    }

    func toString() -> String {
        var string = "Score: " + String(score)
        for userName in userNamesOfPlayers {
            string += "\n" + userName
        }
        return string
    }
}

extension ScoreRecord: Comparable {
    static func < (lhs: ScoreRecord, rhs: ScoreRecord) -> Bool {
        lhs.score < rhs.score
    }

    static func == (lhs: ScoreRecord, rhs: ScoreRecord) -> Bool {
        lhs.score == rhs.score &&
            lhs.userNamesOfPlayers == rhs.userNamesOfPlayers
    }
}
