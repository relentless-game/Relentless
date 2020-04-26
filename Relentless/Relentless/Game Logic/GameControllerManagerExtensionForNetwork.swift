//
//  GameControllerManagerForNetwork.swift
//  Relentless
//
//  Created by Chow Yi Yin on 12/4/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

extension GameControllerManager {
    /// Player joins the game and with user defined username
    internal func joinGame(gameId: Int, userName: String, avatar: PlayerAvatar) {
        guard let userId = self.userId else {
            return
        }

        network.joinGame(userId: userId, userName: userName, avatar: avatar, gameId: gameId, completion: { error in

            if let error = error {
                self.handleUnsuccessfulJoin(error: error)
            } else { // successfully joined the game
                self.handleSuccessfulJoin(userName: userName, userId: userId, avatar: avatar, gameId: gameId)
            }
        })
    }

    func endGame() {
        guard let gameId = gameId else {
            return
        }
        network.terminateGame(gameId: gameId, isGameEndedPrematurely: false)
    }

    func pauseRound() {
        guard let gameId = gameId, var newGameStatus = gameStatus else {
            return
        }

        newGameStatus.numberOfPlayersPaused += 1
        newGameStatus.isResumed = false
        gameStatus = newGameStatus

        let numberOfPlayersPaused = newGameStatus.numberOfPlayersPaused
        if numberOfPlayersPaused == 1 {
            let timer = Timer(timeInterval: 1.0, target: self, selector: #selector(decrementPauseTimer),
                              userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .default)
            pauseTimer = timer
        }

        network.updateGameStatus(gameId: gameId, gameStatus: newGameStatus)
    }

    func resumeRound() {
        guard let gameId = gameId, let roundNumber = game?.currentRoundNumber, var newGameStatus = gameStatus else {
            return
        }

        newGameStatus.numberOfPlayersPaused -= 1
        gameStatus = newGameStatus

        // only resume if all players are back
        let areAllPlayersBack = newGameStatus.numberOfPlayersPaused == 0
        if areAllPlayersBack {
            network.resumeRound(gameId: gameId, currentRound: roundNumber)
        } else {
            network.updateGameStatus(gameId: gameId, gameStatus: newGameStatus)
        }
    }

    @objc
    func endRound() {
        game?.resetForNewRound()
        guard let gameId = gameId, let roundNumber = game?.currentRoundNumber else {
            return
        }
        network.terminateRound(gameId: gameId, roundNumber: roundNumber)
        network.resetPlayersOutOfOrders(gameId: gameId)
    }

    /// Enables the player to edit their username and profile image before the game starts
    func editUserInfo(username: String, profile: PlayerAvatar) {
        guard let gameId = gameId, let userId = userId else {
            return
        }
        network.editUserInfo(userId: userId, gameId: gameId,
                             username: username, profile: profile)
    }

    @objc
    func leaveGame(userId: String) {
        guard let gameId = gameId else {
            return
        }
        game = nil
        network.quitGame(userId: userId, gameId: gameId)
    }

    func sendPackage(package: Package, to destination: Player) -> Bool {
        guard let gameId = gameId else {
            return false
        }
        network.sendPackage(gameId: gameId, package: package, to: destination)
        game?.removePackage(package: package)
        return true
    }

    @objc
    internal func decrementPauseTimer() {
        guard let gameId = gameId else {
            return
        }
        pauseCountDown -= 1
        network.updatePauseCountDown(gameId: gameId, countDown: pauseCountDown)

        // end the game if count down reaches 0
        if pauseCountDown == 0 {
            endGame()
        }
    }

    internal func handleUnsuccessfulJoin(error: JoinGameError) {
        switch error {
        case .invalidGameId:
            NotificationCenter.default.post(name: .invalidGameId, object: nil)
        case .gameAlreadyPlaying:
            NotificationCenter.default.post(name: .gameAlreadyPlaying, object: nil)
        case .gameRoomFull:
            NotificationCenter.default.post(name: .gameRoomFull, object: nil)
        }
    }

    internal func handleSuccessfulJoin(userName: String, userId: String, avatar: PlayerAvatar, gameId: Int) {
        let player = Player(userId: userId, userName: userName, profileImage: avatar)
        self.game = GameManager(gameId: gameId, player: player)
        attachNetworkListeners(userId: userId, gameId: gameId)
        NotificationCenter.default.post(name: .didJoinGame, object: nil)
    }

    @objc
    internal func attachNetworkListeners(userId: String, gameId: Int) {
        attachNonHostListeners(userId: userId, gameId: gameId)
        // The host should not have this listener
        self.network.attachConfigValuesListener(gameId: gameId, action: { configValues in
            self.gameParameters = GameParametersParser(configValues: configValues).parse()
        })
    }

    internal func attachNonHostListeners(userId: String, gameId: Int) {
        self.network.attachPlayerJoinListener(gameId: gameId, action: self.onNewPlayerDidJoin)
        self.network.attachGameStatusListener(gameId: gameId, action: self.onGameStatusDidChange)
        self.network.attachTeamSatisfactionListener(gameId: gameId,
                                                    action: self.onTeamSatisfactionChange)
        self.network.attachItemsListener(userId: userId, gameId: gameId, action: { items in
            self.game?.player.items = Set(items)
        })
        self.network.attachItemSpecificationsListener(userId: userId, gameId: gameId,
                                                      action: { roundItemSpecifications in
            self.game?.roundItemSpecifications = roundItemSpecifications
        })
        self.network.attachOrdersListener(userId: userId, gameId: gameId, action: { orders in
            self.initialiseHouses(with: orders)
        })
        self.network.attachPackageListener(userId: userId, gameId: gameId, action: { package in
            self.game?.addPackage(package: package)
        })
        self.network.attachPauseCountDownListener(gameId: gameId, action: self.onPauseCountDownDidChange)
        self.network.attachPackageItemsLimitListener(gameId: gameId, action: { limit in
            self.game?.packageItemsLimit = limit
        })
    }

    internal func onPauseCountDownDidChange(countdown: Int) {
        pauseCountDown = countdown
        NotificationCenter.default.post(name: .didUpdateCountDown, object: nil)
    }

    internal func onNewPlayerDidJoin(players: [Player]) {
        game?.allPlayers = players
        // change the player itself
        for player in players where player.userId == self.userId {
            game?.player.userName = player.userName
            game?.player.profileImage = player.profileImage
        }
        NotificationCenter.default.post(name: .newPlayerDidJoin, object: nil)
    }

    // for game status listener
    internal func onGameStatusDidChange(gameStatus: GameStatus) {
        // update game status
        self.gameStatus = gameStatus
        print("game status is \(gameStatus)")

        if gameStatus.didEndGamePrematurely {
            handleGameEnd()
            NotificationCenter.default.post(name: .didEndGamePrematurely, object: nil)
        } else if gameStatus.didStartGame {
            NotificationCenter.default.post(name: .didStartGame, object: nil)
        } else if gameStatus.didEndGame /*|| didRunOutPauseTime*/ {
            handleGameEnd()
            NotificationCenter.default.post(name: .didEndGame, object: nil)
        } else if gameStatus.didStartRound {
            handleRoundStart()
            NotificationCenter.default.post(name: .didStartRound, object: nil)
            game?.incrementRoundNumber()
        } else if gameStatus.didEndRound {
            handleRoundEnd()
            NotificationCenter.default.post(name: .didEndRound, object: nil)
        } else if gameStatus.didPauseRound {
            pauseAllTimers()
            NotificationCenter.default.post(name: .didPauseRound, object: nil)
        } else if gameStatus.didResumeRound {
            pauseTimer?.invalidate()
            resumeAllTimers()
            NotificationCenter.default.post(name: .didResumeRound, object: nil)
        }
    }

    @objc
    internal func onTeamSatisfactionChange(satisfactionLevels: [Float]) {
        let numberOfPlayers = game?.allPlayers.count
        // only sum up the satisfaction levels if every player's is received
        if satisfactionLevels.count == numberOfPlayers {
            let sum = satisfactionLevels.reduce(0) { result, number in
                result + number
            }
            updateMoney(satisfactionLevel: Int(sum))
        }
    }

    internal func generateDummyUserName() -> String {
        let random = Int.random(in: 1...100)
        return "Player " + String(players.count + random)
    }
}
