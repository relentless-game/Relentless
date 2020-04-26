//
//  GameOverViewController.swift
//  Relentless
//
//  Created by Chow Yi Yin on 4/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
import UIKit

class GameOverViewController: UIViewController {

    @IBOutlet private var backToMainMenuButton: UIButton!
    @IBOutlet private var scoresView: UITableView!
    var scores: [ScoreRecord]?

    private let scoreIdentifier = "scoreCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        scoresView.rowHeight = UITableView.automaticDimension
        scoresView.estimatedRowHeight = 400
    }

    @IBAction private func backToMainMenu(_ sender: UIButton) {
        removeAllPreviousViewControllers()
        performSegue(withIdentifier: "backToMainMenu", sender: self)
    }
}

extension GameOverViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        scores?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: scoreIdentifier, for: indexPath)
            as? ScoreCell else {
            return tableView.dequeueReusableCell(withIdentifier: scoreIdentifier, for: indexPath)
        }
        guard let score = scores?[indexPath.row] else {
            return cell
        }
        cell.setScore(scoreRecord: score)
        return cell
    }
}
