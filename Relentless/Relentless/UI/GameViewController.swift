//
//  GameViewController.swift
//  Relentless
//
//  Created by Yanch on 17/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

/// Appears before the start of every round. It gives an update of the money left and number of days passed.
class GameViewController: UIViewController {
    @IBOutlet private var proceedButton: UIButton!
    @IBOutlet private var detailsLabel: UILabel!
    @IBOutlet private var newDayLabel: UILabel!

    var gameController: GameController?
    private var timer: Timer?
    private var gameHasEnded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        initProceedButton()
        updateNewDayLabel()
        updateMoneyLabel()
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRoundStarted),
                                               name: .didStartRound, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleGameEnded),
                                               name: .didEndGame, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateMoneyLabel),
                                               name: .didChangeMoney, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .didStartRound, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didEndGame, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didChangeMoney, object: nil)
    }

    private func initProceedButton() {
        proceedButton.isHidden = !(gameController?.isHost ?? false)
    }
    
    private func updateNewDayLabel() {
        guard let roundNumber = gameController?.game?.currentRoundNumber else {
            return
        }
        
        let message: String
        if roundNumber == 0 {
            message = "Are you ready for Day 1?"
        } else {
            message = "Day \(roundNumber) has just ended! Are you ready for Day \(roundNumber + 1)?"
        }
        
        newDayLabel.text = message
    }

    @IBAction private func proceed(_ sender: Any) {
        if gameHasEnded {
            gameHasEnded = false
            proceedButton.isHidden = !(gameController?.isHost ?? false)
            performSegue(withIdentifier: "endGame", sender: self)
        } else {
            (gameController as? GameHostController)?.startRound()
        }
    }

    @objc private func handleRoundStarted() {
        performSegue(withIdentifier: "startRound", sender: self)
    }

    @objc private func handleGameEnded() {
        proceedButton.isHidden = false
        gameHasEnded = true
    }

    @objc private func updateMoneyLabel() {
        timer?.invalidate()
        guard let money = gameController?.money else {
            return
        }
        generateMoneyLeftText(money: money)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        removeAllPreviousViewControllers()
        removeObservers()
        if segue.identifier == "startRound" {
            let viewController = segue.destination as? PackingViewController
            viewController?.gameController = gameController
        } else if segue.identifier == "endGame" {
            let viewController = segue.destination as? GameOverViewController
            do {
                try viewController?.scores = gameController?.getExistingScores()
            } catch {
                viewController?.scores = []
            }
        }
    }

    private func generateMoneyLeftText(money: Int) {
        if money > 0 {
            detailsLabel.text = "You have $" + String(money) + " left"
        } else if money == 0 {
            detailsLabel.text = "You currently have no money"
        } else {
            detailsLabel.text = "You are in debt! You owe $" + String(abs(money))
        }
    }
}
