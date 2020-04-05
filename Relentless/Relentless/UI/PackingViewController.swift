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
    @IBOutlet private var openBoxImageView: UIImageView!

    // items will be updated when the category is changed
    var items: [Category: [Item]]?
    var packages: [Package]?
    var currentCategory: Category?
    var currentPackage: Package?
    var currentPackageItems: [Item]?
    var packageForDelivery: Package?
    private let categoryIdentifier = "CategoryViewController"
    private let itemIdentifier = "ItemCell"
    private let packageIdentifier = "PackageCell"
    private let addPackageIdentifier = "AddPackageButton"

    var assemblyMode = false
    var selectedParts = Set<Part>()

    override func viewDidLoad() {
        super.viewDidLoad()
        initialiseCollectionViews()
        addObservers()
        reloadAllViews()
        registerBackgroundTask()
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleItemLimitReached),
                                               name: .didItemLimitReached, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadCurrentPackage),
                                               name: .didChangeOpenPackage, object: nil)
        // The following observers are for the pausing feature
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppMovedToBackground),
                                               //name: UIApplication.willResignActiveNotification, object: nil)
                                               name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppMovedToForeground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRoundPaused),
                                               name: .didPauseRound, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRoundResumed),
                                               name: .didResumeRound, object: nil)

    }

    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .didStartRound, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didChangePackages, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didChangeItems, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didChangeSatisfactionBar, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didEndRound, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didChangeOpenPackage, object: nil)
        // The following observers are for the pausing feature
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: .didPauseRound, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didResumeRound, object: nil)
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
        currentPackage = gameController?.retrieveOpenPackage()
        currentPackageLabel.text = gameController?.openedPackage?.toString()
        reloadOpenBoxView()
        packages = gameController?.playerPackages
        packagesView.reloadData()
    }

    func reloadOpenBoxView() {
        openBoxImageView.isHidden = currentPackage == nil
    }

    func reloadItems() {
        items = gameController?.playerItems

        if let newCategory = items?.keys.first {
            changeCurrentCategory(to: newCategory)
        }

        itemsView.reloadData()
    }

    @objc func reloadCurrentPackage() {
        currentPackage = gameController?.retrieveOpenPackage()
        reloadOpenBoxView()
        currentPackageItems = gameController?.retrieveItemsFromOpenPackage()
        currentPackageView.reloadData()
        currentPackageLabel.text = gameController?.openedPackage?.toString()
        packagesView.reloadData()
    }

    @objc func updateSatisfactionBar() {
        if let value = gameController?.satisfactionBar.currentFractionalSatisfaction {
            satisfactionBar.setProgress(value, animated: true)
        }
    }
    
    @objc func handleRoundEnded() {
        performSegue(withIdentifier: "endRound", sender: self)
    }

    @objc func handleItemLimitReached() {
        let alert = createAlert(title: "You can't add any more items!",
                                message: "If you still have items to add, "
                                    + "try placing the items into the package in a different order.",
                                action: "Ok.")
        self.present(alert, animated: true, completion: nil)
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
        if longPressGR.state != .began {
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

    @IBAction private func touchAssembleButton(_ sender: Any) {
        if assemblyMode {
            assembleParts()
            selectedParts.removeAll()
            assemblyMode = false
            currentPackageView.reloadData()
        } else {
            assemblyMode = true
            currentPackageView.reloadData()
        }
    }

    func assembleParts() {
        do {
            let parts = Array(selectedParts)
            try gameController?.constructAssembledItem(parts: parts)
        } catch ItemAssembledError.assembledItemConstructionError {
            // Currently, do nothing. Invalid selection of parts by player.
        } catch {
            assert(false, "Unexpected error.")
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
        removeAllPreviousViewControllers()
        if segue.identifier == "toHouses" {
            let viewController = segue.destination as? HousesViewController
            viewController?.gameController = gameController
        }
        if segue.identifier == "deliverPackage" {
            let viewController = segue.destination as? DeliveryViewController
            viewController?.gameController = gameController
            viewController?.packageForDelivery = packageForDelivery
        }
        if segue.identifier == "endRound" {
            removeBackgroundObservers() // prevent background observers from responding to notifs
            let viewController = segue.destination as? GameViewController
            viewController?.gameController = gameController
        }
        // for background pausing feature
        if segue.identifier == "pauseGame" {
            let viewController = segue.destination as? PauseViewController
            viewController?.gameController = gameController
            NotificationCenter.default.removeObserver(self, name: .didPauseRound, object: nil)
        }
    }
    
    // The following methods are for the pausing feature
    
    // Called before segue to Game VC at the end of a round
    private func removeBackgroundObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willResignActiveNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willEnterForegroundNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: .didPauseRound,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: .didResumeRound,
                                                  object: nil)
    }
    
    @objc private func handleAppMovedToForeground() {
        endBackgroundTask()
        gameController?.resumeRound()
        if backgroundTask ==  .invalid {
            registerBackgroundTask()
        }
    }

    @objc private func handleRoundPaused() {
        performSegue(withIdentifier: "pauseGame", sender: self)
    }
    
    private func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
    private func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    @objc private func handleRoundResumed() {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRoundPaused),
                                               name: .didPauseRound, object: nil)
    }
    
    @objc private func handleAppMovedToBackground() {
        gameController?.pauseRound()
    }

    private func createAlert(title: String, message: String, action: String) -> UIAlertController {
        let controller = UIAlertController(title: String(title),
                                           message: String(message),
                                           preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: String(action),
                                          style: .default)
        controller.addAction(defaultAction)
        return controller
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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

    //swiftlint:disable cyclomatic_complexity
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.packagesView {
            if indexPath.item == packages?.count {
                // Add Button at the end.
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: addPackageIdentifier, for: indexPath)
                if let addPackageButton = cell as? AddPackageButton, let avatar = gameController?.player?.profileImage {
                    addPackageButton.setAvatar(to: avatar)
                }
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: packageIdentifier, for: indexPath)

            if let packageCell = cell as? PackageCell, let package = packages?[indexPath.row] {
                packageCell.setPackage(package: package)
                packageCell.active = false
                if package == currentPackage {
                    packageCell.active = true
                }
            }
            return cell
        } else if collectionView == self.currentPackageView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemIdentifier, for: indexPath)
            if let itemCell = cell as? ItemCell, let item = currentPackageItems?[indexPath.row] {
                itemCell.setItem(item: item)
                itemCell.state = .opaque
                if assemblyMode {
                    if let part = currentPackageItems?[indexPath.row] as? Part {
                        if selectedParts.contains(part) {
                            itemCell.state = .opaque
                        } else {
                            itemCell.state = .translucent
                        }
                    } else {
                        itemCell.state = .transparent
                    }
                }
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
            if assemblyMode {
                guard let part = currentPackageItems[indexPath.item] as? Part else {
                    return
                }
                if selectedParts.contains(part) {
                    selectedParts.remove(part)
                } else {
                    selectedParts.insert(part)
                }
            } else {
                gameController?.removeItem(item: currentPackageItems[indexPath.item])
            }
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
            if indexPath.item == packages?.count {
                //addButton
                let width = collectionView.frame.height - 5
                let height = collectionView.frame.height - 5
                return CGSize(width: width, height: height)
            }
            let width = collectionView.frame.width / 6 - 5
            let height = collectionView.frame.height - 5
            return CGSize(width: width, height: height)
        } else {
            let width = collectionView.frame.width / 3.1
            let height = collectionView.frame.height / 2.1
            return CGSize(width: width, height: height)
        }
    }
}
