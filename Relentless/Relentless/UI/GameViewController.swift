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
    var calculatingMoneyStrings = ["Calculating money.", "Calculating money..", "Calculating money..."]
    var calculatingMoneyStringsIndex = 0
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        initProceedButton()
        showCalculatingMoneyLabel()
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

    func showCalculatingMoneyLabel() {
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(changeLabel), userInfo: nil, repeats: true)
    }

    @objc func changeLabel() {
        detailsLabel.text = calculatingMoneyStrings[calculatingMoneyStringsIndex]
        calculatingMoneyStringsIndex = (calculatingMoneyStringsIndex + 1) % calculatingMoneyStrings.count
    }

    func initProceedButton() {
        proceedButton.isHidden = !(gameController?.isHost ?? false)
    }

    @IBAction private func proceed(_ sender: Any) {
        (gameController as? GameHostController)?.startRound()
    }

    @objc func handleRoundStarted() {
        performSegue(withIdentifier: "startRound", sender: self)
    }

    @objc func handleGameEnded() {
        performSegue(withIdentifier: "endGame", sender: self)
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
            detailsLabel.text = "You are in debt! You owe $" + String(money)
        }
    }
}
