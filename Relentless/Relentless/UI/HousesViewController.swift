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
    var didEndRound = false
    @IBOutlet private var housesCollectionView: UICollectionView!
    @IBOutlet private var satisfactionBar: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initCollectionView()
        addObservers()
        houses = gameController?.houses
        updateSatisfactionBar()
    }

    func initCollectionView() {
        let itemNib = UINib(nibName: housesIdentifier, bundle: nil)
        housesCollectionView.register(itemNib, forCellWithReuseIdentifier: housesIdentifier)
    }

    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRoundEnded),
                                               name: .didEndRound, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateSatisfactionBar),
                                               name: .didChangeSatisfactionBar, object: nil)
    }

    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .didEndRound, object: nil)
    }

    @objc func updateSatisfactionBar() {
        if let value = gameController?.satisfactionBar.currentFractionalSatisfaction {
            satisfactionBar.setProgress(Float(value), animated: false)
        }
    }

    @objc func handleRoundEnded() {
        didEndRound = true
    }

    @IBAction private func handleReturnToPackingView(_ sender: Any) {
        if !didEndRound {
            dismiss(animated: true, completion: nil)
        }
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
            let height = view.frame.height - 60
            viewController.preferredContentSize = CGSize(width: width, height: height)
            viewController.modalPresentationStyle = .popover
            viewController.orders = orders
            if let pres = viewController.presentationController {
                pres.delegate = self
            }
            if let pop = viewController.popoverPresentationController {
                pop.sourceView = self.view
                pop.sourceRect = CGRect(x: 0, y: 0, width: 0, height: 0)
                pop.permittedArrowDirections = []
//                pop.sourceView = sender
//                pop.sourceRect = sender.bounds
//                pop.permittedArrowDirections = .up
            }
            self.present(viewController, animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        removeAllPreviousViewControllers()
        removeObservers()
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
