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

    // swiftlint:disable private_outlet
    // Necessary to be accessed in extensions.
    @IBOutlet internal var packagesView: UICollectionView!
    @IBOutlet internal var itemsView: UICollectionView!
    @IBOutlet internal var currentPackageView: UICollectionView!
    // swiftlint:enable private_outlet
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
    let categoryIdentifier = "CategoryViewController"
    let itemIdentifier = "ItemCell"
    let packageIdentifier = "PackageCell"
    let addPackageIdentifier = "AddPackageButton"

    var assemblyMode = false
    var selectedParts = Set<Item>()

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
                                               selector: #selector(handleGameEnded),
                                               name: .didEndGame, object: nil)
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
        NotificationCenter.default.removeObserver(self, name: .didEndGame, object: nil)
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

    @IBAction private func toHouses(_ sender: UIButton) {
        guard let gameStatus = gameController?.gameStatus else {
            return
        }
        let didEndRound = gameStatus.isGamePlaying && !gameStatus.isRoundPlaying && gameStatus.currentRound != 0
        if !didEndRound {
            performSegue(withIdentifier: "toHouses", sender: self)
        } else {
            performSegue(withIdentifier: "endRound", sender: self)
        }
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
            satisfactionBar.setProgress(Float(value), animated: false)
        }
    }
    
    @objc func handleRoundEnded() {
        print("handle round ended")
        removeObservers()
        self.view.isUserInteractionEnabled = false
        
        let message = "This round has ended."
        let alert = createAlert(title: "Uh oh.", message: message, action: "Ok.")
        self.present(alert, animated: true, completion: nil)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            self.performSegue(withIdentifier: "endRound", sender: self)
        }

    }
    
    @objc func handleGameEnded() {
        performSegue(withIdentifier: "endGameFromPacking", sender: self)
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
        categoryButton.setTitle(currentCategory?.categoryName, for: .normal)
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
        if backgroundTask == .invalid {
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
