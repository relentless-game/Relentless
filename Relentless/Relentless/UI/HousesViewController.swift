//
//  HousesViewController.swift
//  Relentless
//
//  Created by Yanch on 20/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class HousesViewController: UIViewController {
    var gameController: GameController?
    var houses: [House]?
    let housesIdentifier = "HouseCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        houses = [House]()
        houses?.append(House(orders: Set<Order>()))
        houses?.append(House(orders: Set<Order>()))
    }
}

extension HousesViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        houses?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: housesIdentifier, for: indexPath)
            if let houseCell = cell as? HouseCell, let house = houses?[indexPath.row] {
                houseCell.setHouse(house: house)
            }
            return cell
    }
}

extension HousesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let houses = houses else {
            return
        }
//        gameController?.openHouse(house: houses[indexPath.item])
    }
}

