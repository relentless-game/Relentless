//
//  PackingViewController.swift
//  Relentless
//
//  Created by Yanch on 16/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import UIKit

class PackingViewController: UIViewController {
    var gameController: GameController?
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    @IBOutlet private var packagesView: UICollectionView!
    @IBOutlet private var itemsView: UICollectionView!
    @IBOutlet private var currentPackageView: UICollectionView!
    @IBOutlet private var currentPackageLabel: UILabel!
    @IBOutlet private var satisfactionBar: UIProgressView!
    @IBOutlet private var categoryButton: UIButton!

    // items will be updated when the category is changed
    var items: [Category: [Item]]?
    var packages: [Package]?
    var currentCategory: Category?
    var currentPackageItems: [Item]?
    var packageForDelivery: Package?
    private let categoryIdentifier = "CategoryViewController"
    private let itemIdentifier = "ItemCell"
    private let packageIdentifier = "PackageCell"
    private let addPackageIdentifier = "AddPackageButton"

    override func viewDidLoad() {
        super.viewDidLoad()
        initialiseCollectionViews()
        addObservers()
        reloadAllViews()
    }

    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadAllViews),
                                               name: .didStartRound, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadPackages),
                                               name: .didChangePackages, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadCurrentPackage),
                                               name: .didChangeItems, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateSatisfactionBar),
                                               name: .didChangeSatisfactionBar, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRoundEnded),
                                               name: .didEndRound, object: nil)
        // The following observers are for the pausing feature
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppMovedToBackground),
                                               name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppMovedToForeground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRoundPaused),
                                               name: .didPauseRound, object: nil)
    }

    func initialiseCollectionViews() {
        attachLongPressToPackages()
        let itemNib = UINib(nibName: itemIdentifier, bundle: nil)
        currentPackageView.register(itemNib, forCellWithReuseIdentifier: itemIdentifier)
        itemsView.register(itemNib, forCellWithReuseIdentifier: itemIdentifier)
    }

    @objc func reloadAllViews() {
        reloadPackages()
        reloadItems()
        reloadCurrentPackage()
        reloadCategoryButton()
        updateSatisfactionBar()
    }
    
    @objc func reloadPackages() {
        packages = gameController?.playerPackages
        packagesView.reloadData()
    }

    func reloadItems() {
        items = gameController?.playerItems

        if let newCategory = items?.keys.first {
            changeCurrentCategory(to: newCategory)
        }

        itemsView.reloadData()
    }

    @objc func reloadCurrentPackage() {
        currentPackageItems = gameController?.retrieveItemsFromOpenPackage()
        currentPackageView.reloadData()
        currentPackageLabel.text = gameController?.openedPackage?.toString()
    }

    @objc func updateSatisfactionBar() {
        if let value = gameController?.satisfactionBar.currentFractionalSatisfaction {
            satisfactionBar.setProgress(value, animated: true)
        }
    }
    
    @objc func handleRoundEnded() {
        performSegue(withIdentifier: "endRound", sender: self)
    }

    func changeCurrentCategory(to category: Category) {
        currentCategory = category
        reloadCategoryButton()
        itemsView.reloadData()
    }

    func reloadCategoryButton() {
        categoryButton.setTitle(currentCategory?.toString(), for: .normal)
    }

    func attachLongPressToPackages() {
        let longPressGR = UILongPressGestureRecognizer(target: self,
                                                       action: #selector(handlePackageLongPress(longPressGR:)))
        longPressGR.minimumPressDuration = 0.5
        longPressGR.delaysTouchesBegan = true
        self.packagesView.addGestureRecognizer(longPressGR)
    }

    @objc
    func handlePackageLongPress(longPressGR: UILongPressGestureRecognizer) {
        if longPressGR.state != .ended {
            return
        }

        let point = longPressGR.location(in: self.packagesView)
        let indexPath = self.packagesView.indexPathForItem(at: point)

        if let indexPath = indexPath {
            if indexPath.item == packages?.count {
                // addButton
                return
            }
            let cell = self.packagesView.cellForItem(at: indexPath)
            if let packageCell = cell as? PackageCell {
                packageForDelivery = packageCell.package
                performSegue(withIdentifier: "deliverPackage", sender: self)
            }
        }
    }

    @IBAction private func touchCategoryButton(_ sender: UIView) {
        if let viewController = self.storyboard?.instantiateViewController(identifier: categoryIdentifier)
            as? CategoryViewController {
            let width = view.frame.width - 60
            let height = view.frame.width / 2
            viewController.preferredContentSize = CGSize(width: width, height: height)
            viewController.modalPresentationStyle = .popover
            if let categoriesAsKeys = items?.keys {
                viewController.categories = Array(categoriesAsKeys)
            }
            viewController.categories = [Category.book, Category.magazine]
            viewController.categoryChangeDelegate = self
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
        print("here")
        removeAllPreviousViewControllers()
        if segue.identifier == "toHouses" {
            print("here1")
            let viewController = segue.destination as? HousesViewController
            viewController?.gameController = gameController
        }
        if segue.identifier == "deliverPackage" {
            print("here2")
            let viewController = segue.destination as? DeliveryViewController
            viewController?.gameController = gameController
            viewController?.packageForDelivery = packageForDelivery
        }
        if segue.identifier == "endRound" {
            print("here3")
            let viewController = segue.destination as? GameViewController
            viewController?.gameController = gameController
        }
        // for pausing feature
        if segue.identifier == "pauseGame" {
            print("prepare for segue to pause game")
            let viewController = segue.destination as? PauseViewController
            viewController?.gameController = gameController
        }
    }

    // The following methods are for the pausing feature
    // TODO: end it before segue
    @objc func handleAppMovedToForeground() {
        gameController?.resumeRound()
        guard let numberOfPlayersPaused = gameController?.gameStatus?.numberOfPlayersPaused else {
            return
        }

        if numberOfPlayersPaused == 0 {
            //timer?.invalidate()
        } else {
            // performSegue(withIdentifier: "pauseGame", sender: self)
        }
    }

    @objc func handleRoundPaused() {
        print("received notification did round pause")
        performSegue(withIdentifier: "pauseGame", sender: self)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
    @objc func handleAppMovedToBackground() {
        print("App moved to background!")
        gameController?.pauseRound()
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        
        let numberOfPlayersPaused = gameController?.gameStatus?.numberOfPlayersPaused
        if numberOfPlayersPaused == 1 {
            assert(backgroundTask != .invalid)
        }
    }
}

extension PackingViewController: CategoryChangeDelegate {
    func setCategory(_ category: Category) {
        changeCurrentCategory(to: category)
    }
}

extension PackingViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        .none
    }
}

extension PackingViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.packagesView {
            return 1 + (packages?.count ?? 0)
        } else if collectionView == self.currentPackageView {
            return currentPackageItems?.count ?? 0
        } else {
            guard let currentCategory = currentCategory else {
                return 0
            }
            return items?[currentCategory]?.count ?? 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.packagesView {
            if indexPath.item == packages?.count {
                // Add Button at the end.
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: addPackageIdentifier, for: indexPath)
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: packageIdentifier, for: indexPath)

            if let packageCell = cell as? PackageCell, let package = packages?[indexPath.row] {
                packageCell.setPackage(package: package)
            }
            return cell
        } else if collectionView == self.currentPackageView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemIdentifier, for: indexPath)
            if let itemCell = cell as? ItemCell, let item = currentPackageItems?[indexPath.row] {
                itemCell.setItem(item: item)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemIdentifier, for: indexPath)
            if let currentCategory = currentCategory,
                let itemCell = cell as? ItemCell,
                let item = items?[currentCategory]?[indexPath.item] {
                itemCell.setItem(item: item)
            }
            return cell
        }
    }
}

extension PackingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.packagesView {
            if indexPath.item == packages?.count {
                // Add Button at the end
                gameController?.addNewPackage()
                reloadPackages()
                return
            }
            guard let packages = packages else {
                return
            }
            gameController?.openPackage(package: packages[indexPath.item])
        } else if collectionView == self.currentPackageView {
            guard let currentPackageItems = currentPackageItems else {
                return
            }
            gameController?.removeItem(item: currentPackageItems[indexPath.item])
        } else {
            if let currentCategory = currentCategory,
                let item = items?[currentCategory]?[indexPath.item] {
                gameController?.addItem(item: item)
            }
        }
        reloadCurrentPackage()
    }
}

extension PackingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.packagesView {
            let width = collectionView.frame.width / 6
            let height = collectionView.frame.height
            return CGSize(width: width, height: height)
        } else {
            let width = collectionView.frame.width / 3 - 20
            let height = collectionView.frame.height / 2 - 20
            return CGSize(width: width, height: height)
        }
    }
}
