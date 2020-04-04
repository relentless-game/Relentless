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
    private let playerIdentifier = "PlayerCell"

    weak var delegate = UIApplication.shared.delegate as? AppDelegate
    @IBOutlet private var gameIdLabel: UILabel!
    @IBOutlet private var startButton: UIButton!
    @IBOutlet private var playersView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initUserId()
        if let userId = self.userId, gameController == nil {
            // Game has not been created yet, create a game.
            // Difficulty level for `GameParameter` should be determined by settings page
            let gameHostParameters = GameHostParameters(difficultyLevel: 1.0)
            gameController = GameHostControllerManager(userId: userId,
                                                       gameHostParameters: gameHostParameters)
            // TODO: change how username is entered
            createGame(username: "New Player")
        } else {
            // Game has been created and joined.
            initAll()
        }
        refreshPlayers()
        addObservers()
    }

    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshPlayers),
                                               name: .newPlayerDidJoin, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(gameJoined),
                                               name: .didJoinGame, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleGameStarted),
                                               name: .didStartGame, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .newPlayerDidJoin, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didJoinGame, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didStartGame, object: nil)
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

    func initAll() {
        initGameIdLabel()
        initStartButton()
    }

    func initStartButton() {
        startButton.isHidden = !(gameController?.isHost ?? false)
    }

    @objc func handleGameStarted() {
        performSegue(withIdentifier: "startGame", sender: self)
    }

    @objc func gameJoined() {
        gameId = gameController?.gameId
        initAll()
    }
    
    @IBAction private func startGame(_ sender: Any) {
        (gameController as? GameHostController)?.startGame()
    }

    func initGameIdLabel() {
        guard let gameId = gameId else {
            return
        }
        gameIdLabel.text = String(gameId)
    }

    func createGame(username: String) {
        (gameController as? GameHostController)?.createGame(username: username)
    }
    
    @IBAction private func handleBackButtonPressed(_ sender: Any) {
        if gameController?.isHost == true {
            gameController?.endGame()
        }
        removeObservers()
        //dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startGame" {
            let viewController = segue.destination as? GameViewController
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: playerIdentifier, for: indexPath)
        if let playerCell = cell as? PlayerCell, let name = players?[indexPath.row].userName {
            playerCell.setText(to: name)
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
    @IBOutlet private var textLabel: UILabel!

    func setText(to text: String) {
        textLabel.text = text
    }
}
