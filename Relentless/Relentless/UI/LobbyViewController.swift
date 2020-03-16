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

    override func viewDidLoad() {
        super.viewDidLoad()
        gameController = GameControllerManager()
//        teamCodeTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
//        teamCodeTextField.delegate = self
    }

    func joinGame() {
        guard let userId = userId, let gameId = gameId else {
            return
        }
        let result = gameController?.joinGame(userId: userId, userName: LobbyViewController.dummyName, gameId: gameId)
        assert(result ?? false)
    }
}
