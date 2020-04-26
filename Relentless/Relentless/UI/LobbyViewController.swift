//
//  LobbyViewController.swift
//  Relentless
//
//  Created by Yanch on 16/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

/// Allows the user to see other players in the same game, and wait for the game to begin.
/// Only the host can start the game from this screen.
class LobbyViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet private var gameIdLabel: UILabel!
    @IBOutlet private var startButton: UIButton!
    @IBOutlet private var playersView: UICollectionView!
    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var avatarImage: UIImageView!
    @IBOutlet private var settingsButton: UIButton!

    private weak var delegate = UIApplication.shared.delegate as? AppDelegate
    var gameController: GameController?
    var demoModeOn: Bool?
    var gameId: Int?
    private var userId: String?
    private var players: [Player]?
    private let playerIdentifier = "PlayerCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUserId()
        if let userId = self.userId, gameController == nil {
            // Game has not been created yet, create a game.
            // Fetch game parameters from remote config.
            gameController = GameHostControllerManager(userId: userId, demoMode: demoModeOn ?? false)
            // You begin with a default blank name.
            createGame(username: "")
        } else {
            // Game has been created and joined.
            initAll()
        }
        refreshPlayers()
        addObservers()
        initBottomRow()
    }

    private func initBottomRow() {
        if let player = gameController?.player {
            usernameTextField.text = player.userName
            avatarImage.image = PlayerImageHelper.getAvatarImage(for: player.profileImage)
        }
    }

    /// Updates the bottom row image.
    private func updateBottomRow() {
        if let player = gameController?.player {
            avatarImage.image = PlayerImageHelper.getAvatarImage(for: player.profileImage)
        }
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshPlayers),
                                               name: .newPlayerDidJoin, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(gameJoined),
                                               name: .didJoinGame, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleGameStarted),
                                               name: .didStartGame, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInsufficientPlayers),
                                               name: .insufficientPlayers, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNonUniqueUsernames),
                                               name: .nonUniqueUsernames, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNonUniqueAvatars),
                                               name: .nonUniqueAvatars, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .newPlayerDidJoin, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didJoinGame, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didStartGame, object: nil)
        NotificationCenter.default.removeObserver(self, name: .insufficientPlayers, object: nil)
        NotificationCenter.default.removeObserver(self, name: .nonUniqueUsernames, object: nil)
        NotificationCenter.default.removeObserver(self, name: .nonUniqueAvatars, object: nil)
    }

    /// Reloads the players collection view.
    @objc private func refreshPlayers() {
        players = gameController?.players
        players?.sort(by: <)
        playersView.reloadData()
        updateBottomRow()
    }

    private func initUserId() {
        if let delegate = delegate {
            userId = delegate.userId
        }
    }

    private func initAll() {
        initGameIdLabel()
        initStartButton()
        initSettingsButton()
    }

    private func initStartButton() {
        startButton.isHidden = !(gameController?.isHost ?? false)
    }

    private func initSettingsButton() {
        settingsButton.isHidden = !(gameController?.isHost ?? false)
    }

    @IBAction private func navigateToSettings(_ sender: UIButton) {
        performSegue(withIdentifier: "toSettings", sender: self)
    }

    @objc private func handleGameStarted() {
        performSegue(withIdentifier: "startGame", sender: self)
    }

    @objc private func handleInsufficientPlayers() {
        let message = "You do not have enough players. Get your friends to join the game!"
        let alert = createAlert(title: "Sorry.", message: message, action: "Ok.")
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func handleNonUniqueUsernames() {
        let alert = createAlert(title: "Sorry.",
                                message: "All of your names need to be unique. Please change some of your names.",
                                action: "Ok.")
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func handleNonUniqueAvatars() {
        let alert = createAlert(title: "Sorry.",
                                message: "All of your avatars need to be unique. Please change some of your avatars.",
                                action: "Ok.")
        self.present(alert, animated: true, completion: nil)
    }

    @objc private func gameJoined() {
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

    private func initGameIdLabel() {
        guard let gameId = gameId else {
            return
        }
        gameIdLabel.text = String(gameId)
    }

    private func createGame(username: String) {
        // Default avatar is red.
        (gameController as? GameHostController)?.createGame(username: username, avatar: .red)
    }
    
    @IBAction private func handleBackButtonPressed(_ sender: Any) {
        guard let userId = userId else {
            return
        }
        gameController?.leaveGame(userId: userId)
        removeObservers()
        //dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        removeAllPreviousViewControllers()
        if segue.identifier == "startGame" {
            removeObservers()
            let viewController = segue.destination as? GameViewController
            viewController?.gameController = gameController
        } else if segue.identifier == "toSettings" {
            let viewController = segue.destination as? SettingsViewController
            viewController?.gameController = gameController
        }
    }

    private func createAlert(title: String, message: String, action: String) -> UIAlertController {
        let controller = UIAlertController(title: String(title),
                                           message: String(message),
                                           preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: String(action),
                                          style: .default)
        controller.addAction(defaultAction)
        return controller
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
