//
//  LobbyViewController.swift
//  Relentless
//
//  Created by Yanch on 16/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class LobbyViewController: UIViewController, UITextFieldDelegate {
    var gameId: Int?
    var userId: String?
    var gameController: GameController?
    var players: [Player]?

    weak var delegate = UIApplication.shared.delegate as? AppDelegate
    @IBOutlet private var gameIdLabel: UILabel!
    @IBOutlet private var startButton: UIButton!
    @IBOutlet private var playersView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initUserId()
        if let userId = self.userId {
            gameController = GameControllerManager(userId: userId)
        }
        if gameId == nil {
            createGame()
        }
        addObservers()
//        initStartButton()
//        initGameIdLabel()
//        refreshPlayers()
//        players = []
//        players?.append(Player(userId: "yo", userName: "hi", profileImage: nil))
    }

    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshPlayers),
                                               name: .newPlayerDidJoin, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(gameCreated),
                                               name: .didCreateGame, object: nil)
    }

    @objc func refreshPlayers() {
        players = gameController?.players
        playersView.reloadData()
    }

    func initUserId() {
        if let delegate = delegate {
            userId = delegate.userId
        }
    }

    func initStartButton() {
        startButton.isHidden = !(gameController?.isHost ?? false)
    }

    @objc func gameCreated() {
        gameId = gameController?.gameId
        initGameIdLabel()
        initStartButton()
    }

    func initGameIdLabel() {
        guard let gameId = gameId else {
            return
        }
        gameIdLabel.text = String(gameId)
    }

    func createGame() {
        gameController?.createGame()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startGame" {
            let viewController = segue.destination as? GameViewController
            gameController?.startGame()
            viewController?.gameController = gameController
        }
    }
}

extension LobbyViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        players?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCell", for: indexPath)
        if let playerCell = cell as? PlayerCell {
            let name = players?[indexPath.row].userName
            playerCell.textLabel.text = name
        }
        return cell
    }
}

extension LobbyViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3 - 20
        let height = collectionView.frame.height / 2 - 20
        return CGSize(width: width, height: height)
    }
}

class PlayerCell: UICollectionViewCell {
    @IBOutlet fileprivate var textLabel: UILabel!
}
