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
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var avatarImage: UIImageView!

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
        updateViews()
    }

    func updateViews() {
        if let player = gameController?.player {
            usernameTextField.text = player.userName
            avatarImage.image = PlayerImageHelper.getAvatarImage(for: player.profileImage)
        }
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
        updateViews()
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

    @IBAction private func changeName(_ sender: Any) {
        if let avatar = gameController?.player?.profileImage, let username = usernameTextField.text {
            gameController?.editUserInfo(username: username, profile: avatar)
        }
    }

    @IBAction private func changeAvatarLeft(_ sender: Any) {
        if let prevAvatar = gameController?.player?.profileImage,
            let username = gameController?.player?.userName {
            let avatar = PlayerAvatar.getPreviousAvatar(avatar: prevAvatar)
            gameController?.editUserInfo(username: username, profile: avatar)
        }
    }

    @IBAction private func changeAvatarRight(_ sender: Any) {
        if let prevAvatar = gameController?.player?.profileImage,
            let username = gameController?.player?.userName {
            let avatar = PlayerAvatar.getNextAvatar(avatar: prevAvatar)
            gameController?.editUserInfo(username: username, profile: avatar)
        }
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
        // TODO: how do we decide default avatar?
        (gameController as? GameHostController)?.createGame(username: username, avatar: .red)
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
        if let playerCell = cell as? PlayerCell, let player = players?[indexPath.row] {
            playerCell.setPlayer(to: player)
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
