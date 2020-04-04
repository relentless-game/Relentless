//
//  NotificationNameExtension.swift
//  Relentless
//
//  Created by Liu Zechu on 18/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//
import Foundation

extension Notification.Name {

    /// Notifications from within `Model` (for `Model`)
    static let didChangeItemsInPackage = Notification.Name("didChangeItemsInPackage")
    static let didTimeUpdateInOrder = Notification.Name("didTimeUpdateInOrder")
    static let didTimeOutInOrder = Notification.Name("didTimeOutInOrder")
    static let didOrderUpdateInHouse = Notification.Name("didOrderUpdateInHouse")
    static let didChangeAssembledItem = Notification.Name("didChangeAssembledItem")
    static let didItemLimitReachedInPackage = Notification.Name("itemLimitReachedInPackage")

    /// Notifications from `Model`(for `GameControllerManager`)
    static let didChangePackagesInModel = Notification.Name("didChangePackagesInModel")
    static let didChangeItemsInModel = Notification.Name("didChangeItemsInModel")
    static let didOrderUpdateInModel = Notification.Name("didOrderUpdateInModel")
    static let didOrderTimeOutInModel = Notification.Name("didTimeOutInModel")
    static let didItemLimitReachedInModel = Notification.Name("itemLimitReachedInModel")
    static let didChangeOpenPackageInModel = Notification.Name("didChangeOpenPackageInModel")

    /// Notifications from `SatisfactionBar` (for `GameControllerManager`)
    static let didChangeCurrentSatisfaction = Notification.Name("didChangeCurrentSatisfaction")

    /// Notifications from `GameControllerManager` (`forView`)
    static let didCreateGame = Notification.Name("didCreateGame")
    static let didJoinGame = Notification.Name("didJoinGame")
    static let newPlayerDidJoin = Notification.Name("newPlayerDidJoin")
    static let didStartGame = Notification.Name("didStartGame")
    static let didStartRound = Notification.Name("didStartRound")
    static let didPauseRound = Notification.Name("didPauseRound")
    static let didResumeRound = Notification.Name("didResumeRound")
    static let didEndGame = Notification.Name("didEndGame")
    static let didEndRound = Notification.Name("didEndRound")
    static let didEndGamePrematurely = Notification.Name("didEndGamePrematurely")
    static let invalidGameId = Notification.Name("invalidGameId")
    static let gameAlreadyPlaying = Notification.Name("gameAlreadyPlaying")
    static let gameRoomFull = Notification.Name("gameRoomFull")
    static let insufficientPlayers = Notification.Name("insufficientPlayers")
    static let didChangeItems = Notification.Name("didChangeItems")
    static let didChangePackages = Notification.Name("didChangePackages")
    static let didChangeOrders = Notification.Name("didChangeOrders") // order is removed or timer is updated
    static let didOrderTimeOut = Notification.Name("didOrderTimeOut") // an order timed out
    static let didChangeSatisfactionBar = Notification.Name("didChangeSatisfactionBar")
    static let didChangeMoney = Notification.Name("didChangeMoney")
    static let didUpdateCountDown = Notification.Name("didUpdateCountDown") // for pausing
    static let didItemLimitReached = Notification.Name("didItemLimitReached")
    static let didChangeOpenPackage = Notification.Name("didChangeOpenPackage")
}
