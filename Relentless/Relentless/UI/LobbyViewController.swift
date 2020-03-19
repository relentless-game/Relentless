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
    var players: [Player]?

    weak var delegate = UIApplication.shared.delegate as? AppDelegate
    @IBOutlet private var gameIdLabel: UILabel!
    @IBOutlet private var startButton: UIButton!
    @IBOutlet private var playersView: UICollectionView!

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

        // TODO: Add actual Players
//        players = gameController.players
        players = []
        players?.append(Player(userId: "yo", userName: "hi", profileImage: nil))

        if let flowLayout = self.playersView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: self.playersView.bounds.width, height: 120)
        }
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
        gameController?.joinGame(userId: userId, userName: LobbyViewController.dummyName, gameId: gameId)
    }

    func createGame() {
        guard let userId = userId else {
            return
        }
        gameController?.createGame(userId: userId, userName: LobbyViewController.dummyName)
        // TODO: Get actual gameId
        gameId = 0
        // gameId = gameController.gameId
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

extension LobbyViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item + 1)
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
