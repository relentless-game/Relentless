//
//  LobbyViewController.swift
//  Relentless
//
//  Created by Yanch on 16/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class LobbyViewController: UIViewController, UITextFieldDelegate {

    static var nameCharacterLimit = 8
    static var dummyName = "foobar"
    var gameId: Int?
    var userId: String?
    var gameController: GameController?

    weak var delegate = UIApplication.shared.delegate as? AppDelegate
    @IBOutlet private var gameIdLabel: UILabel!
    @IBOutlet private var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let userId = self.userId {
            gameController = GameControllerManager(userId: userId)
        }
        initUserId()
        if gameId == nil {
            createGame()
        } else {
            joinGame()
        }
        initStartButton()
        initGameIdLabel()
    }

    func initUserId() {
        if let delegate = delegate {
            userId = delegate.userId
        }
    }

    func initStartButton() {
        startButton.isHidden = !(gameController?.isHost ?? false)
    }

    func initGameIdLabel() {
        guard let gameId = gameId else {
            return
        }
        gameIdLabel.text = String(gameId)
    }

    func joinGame() {
        guard let userId = userId, let gameId = gameId else {
            return
        }
        let result = gameController?.joinGame(userId: userId, userName: LobbyViewController.dummyName, gameId: gameId)
        //assert(result ?? false)
    }

    func createGame() {
        guard let userId = userId else {
            return
        }
        let result = gameController?.createGame(userId: userId, userName: LobbyViewController.dummyName)
        //assert(result ?? false)
        // TODO: Get actual gameId
        gameId = 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startGame" {
            let viewController = segue.destination as? GameViewController
            gameController?.startGame()
            viewController?.gameController = gameController
        }
    }
}
