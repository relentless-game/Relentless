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

    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        initProceedButton()
    }

    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRoundStarted),
                                               name: .didStartRound, object: nil)
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
           
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startRound" {
            let viewController = segue.destination as? PackingViewController
            viewController?.gameController = gameController
        }
    }
}
