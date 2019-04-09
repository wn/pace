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
//        favouriteRoutes = userSession?.getFavouriteRoutes()
        guard let currentUser = userSession?.currentUser,
            let favouriteRoutes = favouriteRoutes else {
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
            let route = Route(creator: currentUser,
                              name: "Random name",
                              creatorRun: Run(runner: currentUser, checkpoints: [startCp, endCp]))
            favouriteRoutes.append(route)
        }
        self.favourites.reloadData()
//        notificationToken = favouriteRoutes.observe { [unowned self] _ in
//            self.favourites.reloadData()
//        }
    }

    @IBAction func addFavourite() {
        guard let currentUser = userSession?.currentUser else {
            return
        }
        func createCP(lat: Double, long: Double) -> CheckPoint {
            return CheckPoint(location: CLLocation(latitude: lat, longitude: long), time: 0.0, actualDistance: 0.0, routeDistance: 0.0)
        }
        let imageNames = ["cat.jpeg", "dog.jpeg", "seal.jpeg"]
        func createRouteStartingAt(lat: Double, long: Double) -> Route {
            let uuidString = UUID().uuidString
            let index = uuidString.firstIndex(of: "-") ?? uuidString.endIndex
            let randomString = uuidString[..<index]
            let randomImage = imageNames[[Int](0..<3).randomElement()!]
            let checkpoints = [Int](0..<6).map { createCP(lat: lat + Double($0), long: long + Double($0)) }
            let randomRoute = Route(creator: currentUser,
                                    name: String(randomString),
                                    thumbnail: UIImage(named: randomImage)?.jpegData(compressionQuality: 0.8),
                                    creatorRun: Run(runner: currentUser, checkpoints: checkpoints))
            [Int](0..<5).forEach { _ in
                randomRoute.addNewRun(Run(runner: currentUser, checkpoints: [createCP(lat: 1.1, long: 2.1)]))
            }
            return randomRoute
        }
        let manager = CachingStorageManager()
        manager.saveNewRoute(createRouteStartingAt(lat: 1, long: 2)) { if $0 == nil { print("lol") } }
        manager.fetchRoutesWithin(latitudeMin: 1.0, latitudeMax: 3.0, longitudeMin: 1.0, longitudeMax: 3.0) {
            print($0)
        }
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
