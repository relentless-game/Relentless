//
//  ScoreRecord.swift
//  Relentless
//
//  Created by Chow Yi Yin on 3/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

/// This class represents an entry in the score board at the end of the game.
class ScoreRecord: Codable {
    static let dateFormat = "yyyy-MM-dd HH:mm:ss"
    let score: Int
    let userNamesOfPlayers: [String]
    let date: Date
    var isLatestEntry: Bool

    var formattedDate: String {
        let format = DateFormatter()
        format.dateFormat = ScoreRecord.dateFormat
        return format.string(from: date)
    }

    init(score: Int, userNamesOfPlayers: [String], isLatestEntry: Bool) {
        self.score = score
        self.userNamesOfPlayers = userNamesOfPlayers
        self.date = Date()
        self.isLatestEntry = isLatestEntry
    }

    func toString() -> String {
        let string = getScoreString() + "\n" + formattedDate + "\n" + getPlayersString()
        return string
    }

    private func getScoreString() -> String {
        "Score: " + String(score)
    }

    private func getPlayersString() -> String {
        var string = "Players: "
        for userName in userNamesOfPlayers {
            string += "\n" + userName
        }
        return string
    }
}

extension ScoreRecord: Comparable {
    static func < (lhs: ScoreRecord, rhs: ScoreRecord) -> Bool {
        if lhs.score < rhs.score {
            return true
        } else if lhs.score > rhs.score {
            return false
        } else {
            return lhs.date < rhs.date
        }
    }

    static func == (lhs: ScoreRecord, rhs: ScoreRecord) -> Bool {
        lhs.score == rhs.score &&
            lhs.userNamesOfPlayers == rhs.userNamesOfPlayers &&
            lhs.isLatestEntry == rhs.isLatestEntry
    }
}
