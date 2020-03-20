//
//  OrderViewController.swift
//  Relentless
//
//  Created by Chow Yi Yin on 19/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
import UIKit

class OrderViewController: UICollectionViewController {
    var gameController: GameController?
    var house: House?
    var orders: [Order]? {
        guard let houseOrders = house?.orders else {
            return [Order]()
        }
        return Array(houseOrders)
    }

    // todo: connect to storyboard
    private weak var ordersCollectionView: UICollectionView!
    private let reuseIdentifier = "ItemCell"

}

extension OrderViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        orders?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView,
                                   numberOfItemsInSection section: Int) -> Int {
        guard let orders = self.orders else {
            return 0
        }
        return orders[section].items.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                   cellForItemAt indexPath: IndexPath) -> ItemCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ItemCell, let orders = self.orders else {
                return ItemCell()
        }
        cell.setItem(item: orders[indexPath.row].items[indexPath.count])

        return cell
    }

}
