//
//  DrawerViewController.swift
//  Pace
//
//  Created by Ang Wei Neng on 3/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import FaveButton
import RealmSwift

class DrawerViewController: PullUpController {
    var userSession: UserSessionManager?

    @IBOutlet var favouriteButton: FaveButton!
    @IBOutlet var numOfRunners: UILabel!
    var initialState: InitialState = .expanded

    @IBOutlet var startPoint: UILabel!
    @IBOutlet var endPoint: UILabel!
    @IBOutlet var createdBy: UILabel!
    @IBOutlet var distance: UILabel!

    var viewingRoute: Route?

    @IBOutlet var runnersTableView: UITableView!
    var paces: [Run] = []
    let runnerCellIdentifier = "runnerCell"

    enum InitialState {
        case contracted
        case expanded
    }

    @objc
    func startRoute(_ sender: UITapGestureRecognizer) {
        // TODO: Start a run
        // Render route map, show checkpoints, etc
        closeDrawer()
        (parent as? ActivityViewController)?.startingRun()
    }

    // MARK: - IBOutlets

    @IBOutlet private weak var visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var routeStatsContainerView: UIView!
    @IBOutlet private weak var expandedView: UIView!

    @IBOutlet private weak var searchSeparatorView: UIView! {
        didSet {
            searchSeparatorView.layer.cornerRadius = searchSeparatorView.frame.height / 2
        }
    }

    var initialPointOffset: CGFloat {
        return routeStatsContainerView.frame.maxY
    }

    public var portraitSize: CGSize = .zero

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        userSession = RealmUserSessionManager.forDefaultRealm
        portraitSize = CGSize(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height),
                              height: min(UIScreen.main.bounds.height - 75, expandedView.frame.maxY))
    }

    override func pullUpControllerWillMove(to stickyPoint: CGFloat) {
        // print("will move to \(stickyPoint)")
    }

    override func pullUpControllerDidMove(to stickyPoint: CGFloat) {
        // print("did move to \(stickyPoint)")
        if stickyPoint == 0 {
            closeDrawer()
        }
    }

    func closeDrawer() {
        parent?.removePullUpController(self, animated: true)
    }

    override func pullUpControllerDidDrag(to point: CGFloat) {
        // print("did drag to \(point)")
    }

    var tabBarHeight: CGFloat {
        return parent?.tabBarController?.tabBar.frame.height ?? 0
    }

    // MARK: - PullUpController

    override var pullUpControllerPreferredSize: CGSize {
        return portraitSize
    }

    override var pullUpControllerMiddleStickyPoints: [CGFloat] {
        return [0, routeStatsContainerView.frame.maxY]
    }

    override var pullUpControllerBounceOffset: CGFloat {
        return 0
    }

    override func pullUpControllerAnimate(action: PullUpController.Action,
                                          withDuration duration: TimeInterval,
                                          animations: @escaping () -> Void,
                                          completion: ((Bool) -> Void)?) {
        switch action {
        case .move:
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0,
                           options: .curveEaseInOut,
                           animations: animations,
                           completion: completion)
        default:
            UIView.animate(withDuration: 0.3,
                           animations: animations,
                           completion: completion)
        }
    }
}

extension DrawerViewController {
    func routeStats(_ route: Route) {
        guard let stats = route.generateStats() else {
            return
        }

        viewingRoute = route

        startPoint.text = "START: \(stats.startingLocation.coordinate)"
        endPoint.text = "END: \(stats.endingLocation.coordinate)"
        createdBy.text = "Created by: \(route.creator?.name ?? "NO NAME SET!")"
        distance.text = "Distance: \(stats.totalDistance)"

        paces = route.paces.sorted { $0.timeSpent < $1.timeSpent }
        numOfRunners.text = "\(paces.count) 🏃🏻‍♂️"

        // Add tap gesture to drawer
        routeStatsContainerView.gestureRecognizers?.removeAll()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(startRoute(_:)))
        routeStatsContainerView.addGestureRecognizer(tapGesture)

        runnersTableView.reloadData()

        // Set favourite flag
//        guard let isFavourite = userSession?.currentUser?.containsFavouriteRoute(route) else {
//            return
//        }
        favouriteButton.setSelected(selected: false, animated: false)
    }
}

/// MARK: - Runner's table configuration
extension DrawerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paces.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: runnerCellIdentifier, for: indexPath)
            as! RunnerTableViewCell
        let row = indexPath.row
        let pace = paces[indexPath.row]
        cell.setupCell(pos: row + 1, name: pace.runner?.name ?? "No name", time: Int(pace.timeSpent))
        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let headerHeight = runnersTableView.headerView(forSection: 1)?.frame.height ?? 0
        return (expandedView.frame.height - headerHeight) / 7
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        _ = indexPath.row
    }

    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        return "Run Statistics"
    }

    func tableView(_ tableView: UITableView,
                   titleForFooterInSection section: Int) -> String? {
        return nil
    }
}

extension DrawerViewController: FaveButtonDelegate {
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool) {
        guard let currentRoute = viewingRoute else {
            return
        }
        guard let user = userSession?.currentUser else {
            let alert = UIAlertController(
                title: "Not logged in",
                message: "You need to be logged in to favourite a route.",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            faveButton.isSelected = false
            return
        }
//        if selected {
//            print("FAVOURITE-ED")
//            guard user.addFavouriteRoute(currentRoute) else {
//                let alert = UIAlertController(
//                    title: "No connection",
//                    message: "Can't connect to the internet now, try again later.",
//                    preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                present(alert, animated: true)
//                return
//            }
//            print(user.containsFavouriteRoute(currentRoute))
//        } else {
//            // WE REMOVE FROM FAVOURITE
//            print("UN-FAVOURITE-ED")
//            guard user.removeFavouriteRoute(currentRoute) else {
//                let alert = UIAlertController(
//                    title: "No connection",
//                    message: "Can't connect to the internet now, try again later.",
//                    preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                present(alert, animated: true)
//                return
//            }
//            print(user.containsFavouriteRoute(currentRoute))
//        }
    }
}
