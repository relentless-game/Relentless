//
//  JsonScoreBoardStorage.swift
//  Relentless
//
//  Created by Chow Yi Yin on 3/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class JsonScoreBoardStorage: ScoreBoard {

    var scores = Data()
    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    let jsonFile = "RelentlessScores.json"

    func getExistingScores() throws -> [ScoreRecord] {
        let url = try getDocumentsURL().appendingPathComponent(jsonFile)
        // create the file if it does not already exist
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
        do {
            let data = try Data(contentsOf: url, options: [])
            if data.isEmpty {
                return [ScoreRecord]()
            }
            // scores are assumed to be sorted when saved
            let scores = try jsonDecoder.decode([ScoreRecord].self, from: data)
            return scores
        } catch {
            throw ScoreBoardError.loadError
        }
    }


    func updateScoreBoard(with newScore: ScoreRecord) throws {
        do {
            var updatedScores = try getExistingScores()
            if updatedScores.isEmpty {
                scores = try jsonEncoder.encode([newScore])
            } else {
                updatedScores.append(newScore)
                updatedScores.sort()
                scores = try jsonEncoder.encode(updatedScores)
            }
            let url = try getDocumentsURL().appendingPathComponent(jsonFile)
            try scores.write(to: url, options: [])
        } catch {
            throw ScoreBoardError.updateError
        }
    }

    private func getDocumentsURL() throws -> URL {
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url
        } else {
            throw ScoreBoardError.loadError
        }
    }
}
