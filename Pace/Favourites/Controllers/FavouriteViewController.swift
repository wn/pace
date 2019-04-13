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
    // MARK: - Properties
    private var favouriteRoutes: List<Route>? = List<Route>()
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let user = user,
            let routes = favouriteRoutes else {
            // Reset data
            favouriteRoutes = List<Route>()
            favourites.reloadData()
            return
        }
        let startCp = CheckPoint(location: CLLocation(latitude: 1.308_012, longitude: 103.773_094),
                                 time: 0,
                                 actualDistance: 0,
                                 routeDistance: 0)
        let endCp = CheckPoint(location: CLLocation(latitude: 1.308_012, longitude: 103.773_094),
                               time: 100,
                               actualDistance: 1.2,
                               routeDistance: 1.2)
        for _ in 0...4 {
            let route = Route(creator: user,
                              name: "Random name",
                              creatorRun: Run(runner: user, checkpoints: [startCp, endCp]))
            routes.append(route)
        }
        //        notificationToken = favouriteRoutes.observe { [unowned self] _ in
        //            self.favourites.reloadData()
        //        }
        self.favourites.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension FavouriteViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // Tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favouriteRoutes?.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: Identifiers.routeCell, for: indexPath) as! RouteCollectionViewCell
        cell.route = favouriteRoutes?[indexPath.item]
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
}
