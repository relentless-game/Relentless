//
//  ScoreCell.swift
//  Relentless
//
//  Created by Chow Yi Yin on 5/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
import UIKit

/// Represents a score from a played game.
class ScoreCell: UITableViewCell {
    static let fontSize: CGFloat = 20
    static let regularFontName = "AppleSDGothicNeo-Regular"
    static let boldedFontName = "AppleSDGothicNeo-Bold"
    @IBOutlet private var score: UILabel!

    func setScore(scoreRecord: ScoreRecord) {
        let text = scoreRecord.toString()
        score.text = text
        score.lineBreakMode = .byWordWrapping
        score.numberOfLines = text.split(separator: "\n").count
        var font = UIFont(name: ScoreCell.regularFontName, size: ScoreCell.fontSize)
        if scoreRecord.isLatestEntry {
            font = UIFont(name: ScoreCell.boldedFontName, size: ScoreCell.fontSize)
        }
        score.font = font
    }

}
