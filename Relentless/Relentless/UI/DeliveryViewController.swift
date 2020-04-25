//
//  DeliveryViewController.swift
//  Relentless
//
//  Created by Yanch on 20/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class DeliveryViewController: UIViewController {
    var gameController: GameController?
    var houses: [House]?
    var otherPlayers: [Player]?
    var packageForDelivery: Package?
    let housesIdentifier = "HouseCell"
    let playersIdentifier = "PlayerIconCell"
    @IBOutlet private var playersCollectionView: UICollectionView!
    @IBOutlet private var housesCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initCollectionViews()
        houses = gameController?.houses
        otherPlayers = gameController?.otherPlayers
    }

    func initCollectionViews() {
        let itemNib = UINib(nibName: housesIdentifier, bundle: nil)
        housesCollectionView.register(itemNib, forCellWithReuseIdentifier: housesIdentifier)
    }

    func returnToPackingView() {
        guard let gameStatus = gameController?.gameStatus else {
            return
        }
        let didEndRound = gameStatus.isGamePlaying && !gameStatus.isRoundPlaying && gameStatus.currentRound != 0
        if !didEndRound {
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction private func handleReturnToPackingView(_ sender: Any) {
        returnToPackingView()
    }
    
    @IBAction private func handleDeletePackage(_ sender: Any) {
        if let package = packageForDelivery {
            gameController?.removePackage(package: package)
        }
        returnToPackingView()
    }
}

extension DeliveryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.housesCollectionView {
            return houses?.count ?? 0
        } else {
            return otherPlayers?.count ?? 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == self.housesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: housesIdentifier, for: indexPath)
            if let houseCell = cell as? HouseCell, let house = houses?[indexPath.row] {
                houseCell.setHouse(house: house)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: playersIdentifier, for: indexPath)
            if let playerIconCell = cell as? PlayerIconCell, let player = otherPlayers?[indexPath.row] {
                playerIconCell.setPlayer(player: player)
            }
            return cell
        }
    }
}

extension DeliveryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.housesCollectionView {
            guard let houses = houses, let packageForDelivery = packageForDelivery else {
                return
            }
            let house = houses[indexPath.item]
            gameController?.deliverPackage(package: packageForDelivery, to: house)
        } else {
            guard let otherPlayers = otherPlayers, let packageForDelivery = packageForDelivery else {
                return
            }
            let player = otherPlayers[indexPath.item]
            _ = gameController?.sendPackage(package: packageForDelivery, to: player)
        }
        returnToPackingView()
    }
}

extension DeliveryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = housesCollectionView.frame.width / 6.6
        let height = housesCollectionView.frame.height / 2.4
        return CGSize(width: width, height: height)
    }
}
