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
        addObservers()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRoundEnded),
                                               name: .didEndRound, object: nil)
    }

    func initCollectionViews() {
        let itemNib = UINib(nibName: housesIdentifier, bundle: nil)
        housesCollectionView.register(itemNib, forCellWithReuseIdentifier: housesIdentifier)
    }

    @objc func handleRoundEnded() {
        performSegue(withIdentifier: "endRound", sender: self)
    }
    
    @IBAction private func handleReturnToPackingView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        removeAllPreviousViewControllers()
        if segue.identifier == "cancelDelivery" {
            let viewController = segue.destination as? PackingViewController
            viewController?.gameController = gameController
        }
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
        // performSegue(withIdentifier: "cancelDelivery", sender: self)
        dismiss(animated: true, completion: nil)
    }
}

class PlayerIconCell: UICollectionViewCell {
    // todo: change to UIImageView
    var player: Player!
    @IBOutlet private var textLabel: UILabel!

    func setPlayer(player: Player) {
        self.player = player
        textLabel.text = player.userName
    }
}
