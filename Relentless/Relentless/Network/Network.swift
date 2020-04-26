//
//  Network.swift
//  Relentless
//
//  Created by Liu Zechu on 13/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

protocol Network {
    
    /// Changes the `GameStatus` to notify other players that the game has ended.
    /// Frees up the game ID stored in the cloud.
    /// - parameters:
    ///     - gameId: the current game ID
    ///     - isGameEndedPrematurely: A host player can call this function
    ///     if they wish to quit the game before the game starts, in which case,
    ///     `isGameEndedPrematurely` should be `true`. Otherwise, it should be `false`.
    func terminateGame(gameId: Int, isGameEndedPrematurely: Bool)
    
    /// This can be called by a player to join the game with the specified game ID.
    /// The host also has to join through this method.
    /// - parameters:
    ///     - completion: a closure that is called to propagate possible errors
    ///     that occur when joining a game. `nil` is passed into it to indicate success.
    func joinGame(userId: String, userName: String, avatar: PlayerAvatar, gameId: Int,
                  completion: @escaping (JoinGameError?) -> Void)

    /// A non-host player can call this function to quit the game before the game starts.
    /// If a host wishes to quit the game, the whole game will terminate,
    /// and the host should use the `terminateGamePrematurely` function.
    func quitGame(userId: String, gameId: Int)

    /// This is called to terminate the current round.
    func terminateRound(gameId: Int, roundNumber: Int)

    /// This is called to pause the current round.
    func pauseRound(gameId: Int, currentRound: Int)

    /// This is called to resume the current round if it is paused.
    func resumeRound(gameId: Int, currentRound: Int)
    
    /// Notifies non-host player to give them their items for this round. `action` is called upon receiving the items.
    func attachItemsListener(userId: String, gameId: Int, action: @escaping ([Item]) -> Void)
    
    /// Notifies non-host player to give them their orders for this round. `action` is called upon receiving the orders.
    func attachOrdersListener(userId: String, gameId: Int, action: @escaping ([Order]) -> Void)
    
    /// This can be called by any player to send a package to the target player.
    func sendPackage(gameId: Int, package: Package, to destination: Player)
    
    /// Notifies the player when a package is received. `action` is called upon receiving a new package.
    func attachPackageListener(userId: String, gameId: Int, action: @escaping (Package) -> Void)
    
    /// Notifies the player when there is a change in the game status, e.g. whether a game/round has started/ended.
    /// `action` is called upon any change in game status.
    func attachGameStatusListener(gameId: Int, action: @escaping (GameStatus) -> Void)

    /// Clears every player's satisfaction level stored in the cloud before a new round starts.
    func resetSatisfactionLevels(gameId: Int)
    
    /// Updates the network about this player's individual satiafaction level so that other players can get notified.
    func updateIndividualSatisfactionLevel(gameId: Int, userId: String, satisfactionLevel: Double)
    
    /// Notifies the player when there is a change in the team satisfaction level.
    /// `action` is called upon a change in the satisfaction level.
    func attachTeamSatisfactionListener(gameId: Int, action: @escaping ([Float]) -> Void)

    /// Deletes all the packages under a player stored in the cloud.
    /// This is called after the player has received the packages from the cloud.
    func deleteAllPackages(userId: String, gameId: Int)

    /// Notifies the player when there is a new player joining in the game.`action` is called
    /// with an array of all players as the argument, when a new player joins.
    func attachPlayerJoinListener(gameId: Int, action: @escaping ([Player]) -> Void)
    
    /// Notifies the network that this player has run out of orders for this round.
    func outOfOrders(userId: String, gameId: Int)

    /// Notifies the player how many players in total are out of orders.
    /// `action` takes in the total number of such players.
    func attachOutOfOrdersListener(gameId: Int, action: @escaping (Int) -> Void)
    
    /// Resets the players out of orders.
    func resetPlayersOutOfOrders(gameId: Int)
    
    /// Enables the user to edit their name and profile image before the game starts.
    func editUserInfo(userId: String, gameId: Int, username: String, profile: PlayerAvatar)

    /// Updates the game status. Currently this is used for pausing/resuming a game.
    func updateGameStatus(gameId: Int, gameStatus: GameStatus)
    
    /// Notifies the user count down to termination of game during the pausing state
    func attachPauseCountDownListener(gameId: Int, action: @escaping (Int) -> Void)
    
    /// Notifies the network count down to termination of game during the pausing state
    func updatePauseCountDown(gameId: Int, countDown: Int)

    /// Notifies the player of the limit for the number of items in packages
    func attachPackageItemsLimitListener(gameId: Int, action: @escaping (Int?) -> Void)

    /// Notifies the player of the config values for the game
    func attachConfigValuesListener(gameId: Int, action: @escaping (LocalConfigValues) -> Void)

    /// Notifies non-host player to give them their item specifications for this round.
    /// `action` is called upon receiving the item specifications.
    func attachItemSpecificationsListener(userId: String, gameId: Int,
                                          action: @escaping (RoundItemSpecifications) -> Void)
}
