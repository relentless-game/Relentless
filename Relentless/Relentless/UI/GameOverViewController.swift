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
    var gameController: GameController?

    private let scoreIdentifier = "ScoreCell"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction private func backToMainMenu(_ sender: UIButton) {
        performSegue(withIdentifier: "backToMainMenu", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToMainMenu" {
            let viewController = segue.destination as? PackingViewController
            viewController?.gameController = gameController
        } else if segue.identifier == "endGame" {
            let viewController = segue.destination as? GameOverViewController
            viewController?.gameController = gameController
            do {
                try viewController?.scores = gameController?.getExistingScores()
            } catch {
                viewController?.scores = []
            }
        }
    }

}

extension GameOverViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        scores?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: scoreIdentifier, for: indexPath)
        guard let score = scores?[indexPath.row] else {
            return cell
        }
        cell.textLabel?.text = score.toString()
        return cell
    }
}
