//
//  OrderViewController.swift
//  Relentless
//
//  Created by Chow Yi Yin on 19/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

/// Shows the orders from a specific house.
class OrderViewController: UIViewController {
    var orders: [Order]?

    private let reuseIdentifier = "ItemCell"
    @IBOutlet private var ordersCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let itemNib = UINib(nibName: reuseIdentifier, bundle: nil)
        ordersCollectionView.register(itemNib, forCellWithReuseIdentifier: reuseIdentifier)
    }
}

extension OrderViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        orders?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let orders = self.orders else {
            return 0
        }
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
        cell.state = .deselected
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
            return headerView
        default:
            return OrderHeaderView()
        }
    }
}

extension OrderViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 4.1
        let height = collectionView.frame.height / 2.1
        return CGSize(width: width, height: height)
    }
}
