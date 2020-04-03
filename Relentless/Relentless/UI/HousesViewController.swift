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
    var activeHouse: House?
    let housesIdentifier = "HouseCell"
    let orderIdentifier = "OrderViewController"
    @IBOutlet private var housesCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initCollectionView()
        addObservers()
        houses = gameController?.houses
    }

    func initCollectionView() {
        let itemNib = UINib(nibName: housesIdentifier, bundle: nil)
        housesCollectionView.register(itemNib, forCellWithReuseIdentifier: housesIdentifier)
    }

    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRoundEnded),
                                               name: .didEndRound, object: nil)
    }
    
    @objc func handleRoundEnded() {
        performSegue(withIdentifier: "endRound", sender: self)
    }

    @IBAction private func handleReturnToPackingView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func openOrders(_ sender: UIView) {
        guard let activeHouse = activeHouse,
            let orders = gameController?.retrieveActiveOrders(for: activeHouse),
            !orders.isEmpty else {
            return
        }
        if let viewController = self.storyboard?.instantiateViewController(identifier: orderIdentifier)
            as? OrderViewController {
            let width = view.frame.width - 60
            let height = view.frame.width / 2
            viewController.preferredContentSize = CGSize(width: width, height: height)
            viewController.modalPresentationStyle = .popover
            viewController.orders = orders
            if let pres = viewController.presentationController {
                pres.delegate = self
            }
            if let pop = viewController.popoverPresentationController {
                pop.sourceView = sender
                pop.sourceRect = sender.bounds
            }
            self.present(viewController, animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        removeAllPreviousViewControllers()
        if segue.identifier == "toPacking" {
            let viewController = segue.destination as? PackingViewController
            viewController?.gameController = gameController
        }
        if segue.identifier == "endRound" {
            let viewController = segue.destination as? GameViewController
            viewController?.gameController = gameController
        }
    }
}

extension HousesViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        .none
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
        activeHouse = houses[indexPath.item]

        if let cell = collectionView.cellForItem(at: indexPath) {
            openOrders(cell)
        }
    }
}
