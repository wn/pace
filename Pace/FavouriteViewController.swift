//
//  FavouriteViewController.swift
//  Pace
//
//  Created by Ang Wei Neng on 21/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import RealmSwift

class FavouriteViewController: UIViewController {
    // MARK: - Properties
    private var favouriteRoutes = User.currentUser?.favouriteRoutes ?? List<Route>()
    private let favouriteCellIdentifier = "favouriteCell"

    @IBOutlet private weak var favourites: UICollectionView!
    @IBOutlet private weak var userIndicator: UILabel!
    
    // Constants for table view
    /// Number of items per row for the `UITableView`
    let itemsPerRow = 1

    /// Section insets for `UITableViewCell`s.
    private let sectionInsets = UIEdgeInsets(top: 0,
                                             left: 20.0,
                                             bottom: 100.0,
                                             right: 20.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favourites.register(UINib(nibName: "FavouriteRouteViewCell", bundle: Bundle.main),
                            forCellWithReuseIdentifier: favouriteCellIdentifier)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if User.currentUser == nil {
            presentUserPrompt()
        }
        updateUserIndicator()
    }
    
    private func presentUserPrompt() {
        let alertController = UIAlertController(title: "Login", message: "Supply a nice nickname!", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Login", style: .default, handler: { [unowned self] alert -> Void in
            let textField = alertController.textFields![0]
            User.currentUser = User.getUser(name: textField.text!)
            self.favouriteRoutes = User.currentUser?.favouriteRoutes ?? List<Route>()
            self.favourites.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.placeholder = "A Name for your user"
        })
        self.present(alertController, animated: true, completion: nil)
    }

    private func updateUserIndicator() {
        userIndicator.text = User.currentUser?.name
    }

    @IBAction func addFavourite() {
        guard let currentUser = User.currentUser else {
            return
        }
        let imageNames = ["cat.jpeg", "dog.jpeg", "seal.jpeg"]
        let uuidString = UUID().uuidString
        let index = uuidString.firstIndex(of: "-") ?? uuidString.endIndex
        let randomString = uuidString[..<index]
        let randomImage = imageNames[[Int](0..<3).randomElement()!]
        let randomRoute = Route(creator: currentUser,
                                name: String(randomString),
                                thumbnail: UIImage(named: randomImage)?.jpegData(compressionQuality: 0.8),
                                creatorRun: Run(runner: currentUser, checkpoints: []))
        currentUser.addFavouriteRoute(randomRoute)
        onFavouriteAdded()
    }
    
    func onFavouriteAdded() {
        favourites.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension FavouriteViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // Tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favouriteRoutes.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: favouriteCellIdentifier, for: indexPath) as! FavouriteRoutesCollectionViewCell
        cell.route = favouriteRoutes[indexPath.item]
        // Configure the cell
        return cell
    }
}

// MARK: - Collection View Flow Layout Delegate
extension FavouriteViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)

        return CGSize(width: widthPerItem, height: widthPerItem / 4)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
