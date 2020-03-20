//
//  OrderViewController.swift
//  Relentless
//
//  Created by Chow Yi Yin on 19/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation
import UIKit

class OrderViewController: UIViewController {
    var gameController: GameController?
    var house: House?
    var orders: [Order]? {
        guard let houseOrders = house?.orders else {
            return [Order]()
        }
        return Array(houseOrders)
    }

    private let reuseIdentifier = "ItemCell"
    @IBOutlet weak var ordersCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let itemNib = UINib(nibName: reuseIdentifier, bundle: nil)
        ordersCollectionView.register(itemNib, forCellWithReuseIdentifier: reuseIdentifier)
    }

}

extension OrderViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print(orders?.count)
        return orders?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let orders = self.orders else {
            return 0
        }
        print(orders[section].items.count)
        return orders[section].items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ItemCell,
            let orders = self.orders else {
                return ItemCell()
        }
        let order = orders[indexPath.section]
        let item = order.items[indexPath.item]
        cell.setItem(item: item)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView
                .dequeueReusableSupplementaryView(ofKind: kind,
                                                  withReuseIdentifier: "OrderHeaderView",
                                                  for: indexPath) as? OrderHeaderView else {
                return OrderHeaderView()
            }
            headerView.setLabel("Order \(indexPath.section)")
            return headerView
        default:
            return OrderHeaderView()
        }
    }
}
