//
//  FavouriteViewController.swift
//  Pace
//
//  Created by Ang Wei Neng on 21/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation

class FavouriteViewController: RequireLoginController {

    private var favouriteRoutes = List<Route>()
    private var notificationToken: NotificationToken?

    @IBOutlet private weak var favourites: UICollectionView!

    // Constants for table view
    /// Number of items per row for the `UITableView`
    let itemsPerRow = 1

    /// Section insets for `UITableViewCell`s.
    private let sectionInsets = UIEdgeInsets(top: 0.0,
                                             left: 0.0,
                                             bottom: 0.0,
                                             right: 0.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Titles.favourites
        favourites.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showRoute)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
    }

    override func loadData() {
        guard let user = user else {
            // Reset data
            print("reset")
            favouriteRoutes = List<Route>()
            favourites.reloadData()
            return
        }
        favouriteRoutes = user.favouriteRoutes
        RealmUserSessionManager.default.getFavouriteRoutes(of: user)
        notificationToken = favouriteRoutes.observe { [unowned self] _ in
            self.favourites.reloadData()
        }
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
            .dequeueReusableCell(withReuseIdentifier: Identifiers.routeCell, for: indexPath) as! RouteCollectionViewCell
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
        return CGSize(width: view.frame.width, height: view.frame.width / 2)
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

    @objc
    func showRoute(sender: UITapGestureRecognizer){
        guard let indexPath = favourites?.indexPathForItem(at: sender.location(in: favourites)) else {
            return
        }
        self.tabBarController?.selectedIndex = 1
        guard let navVC = tabBarController?.selectedViewController as? UINavigationController,
            let activityVC = navVC.topViewController as? ActivityViewController else {
            return
        }
        let _ = activityVC.view
        activityVC.renderRoute(favouriteRoutes[indexPath.row])
    }
}
