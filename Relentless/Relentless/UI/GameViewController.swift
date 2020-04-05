//
//  GameViewController.swift
//  Relentless
//
//  Created by Yanch on 17/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    var gameController: GameController?
    @IBOutlet private var proceedButton: UIButton!
    @IBOutlet private var detailsLabel: UILabel!
    var timer: Timer?
    var gameHasEnded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        initProceedButton()
    }

    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRoundStarted),
                                               name: .didStartRound, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleGameEnded),
                                               name: .didEndGame, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateMoneyLabel(notification:)),
                                               name: .didChangeMoney, object: nil)
    }

    func initProceedButton() {
        proceedButton.isHidden = !(gameController?.isHost ?? false)
    }

    @IBAction private func proceed(_ sender: Any) {
        if gameHasEnded {
            gameHasEnded = false
            performSegue(withIdentifier: "endGame", sender: self)
        } else {
            (gameController as? GameHostController)?.startRound()
        }
    }

    @objc func handleRoundStarted() {
        performSegue(withIdentifier: "startRound", sender: self)
    }

    @objc func handleGameEnded() {
        gameHasEnded = true
    }

    @objc func updateMoneyLabel(notification: Notification) {
        timer?.invalidate()
        guard let money = gameController?.money else {
            return
        }
        generateMoneyLeftText(money: money)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startRound" {
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
