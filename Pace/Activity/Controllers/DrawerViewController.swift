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
import FacebookLogin
import FacebookCore

class DrawerViewController: PullUpController {
    var userSession: UserSessionManager?

    @IBOutlet private var favouriteButton: FaveButton!
    @IBOutlet private var numOfRunners: UILabel!
    var initialState: InitialState = .expanded

    @IBOutlet private var startPoint: UILabel!
    @IBOutlet private var endPoint: UILabel!
    @IBOutlet private var createdBy: UILabel!
    @IBOutlet private var distance: UILabel!

    var viewingRoute: Route?
    var getCurrentUser: User? {
        guard let uid = AccessToken.current?.userId else {
            return nil
        }
        return RealmUserSessionManager.default.getRealmUser(uid)
    }

    @IBOutlet private var runnersTableView: UITableView!
    var paces: [Run] = []
    let runnerCellIdentifier = "runnerCell"

    enum InitialState {
        case contracted
        case expanded
    }

    @objc
    func startRoute(_ sender: UITapGestureRecognizer) {
        guard let run = viewingRoute?.creatorRun else {
            return
        }
        guard (parent as? ActivityViewController)?.startingFollowRun(with: run) ?? false else {
            UIAlertController.showMessage(
                self,
                msg: "You are too far away from the starting point of the route to start the route.")
            return
        }
        closeDrawer()
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

    private var portraitSize: CGSize = .zero

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        userSession = RealmUserSessionManager.default
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
        stats.startingLocation.address { [unowned self] address in
            self.startPoint.text = "Start: \(address ?? "Unknown")"
        }
        stats.endingLocation.address { [unowned self] address in
            self.endPoint.text = "End: \(address ?? "Unknown")"
        }
        createdBy.text = "Created by: \(route.creator?.name ?? "")"
        distance.text = String(format: "Distance: %.2fkm", arguments: [stats.totalDistance / 1_000])
        paces = route.paces.sorted { $0.timeSpent < $1.timeSpent }
        numOfRunners.text = "\(paces.count) 🏃🏻‍♂️"

        // Add tap gesture to drawer
        routeStatsContainerView.gestureRecognizers?.removeAll()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(startRoute(_:)))
        routeStatsContainerView.addGestureRecognizer(tapGesture)

        runnersTableView.reloadData()
        // Set favourite flag
        let isFavourite = getCurrentUser?.isFavouriteRoute(route) ?? false
        favouriteButton.setSelected(selected: isFavourite, animated: false)
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
        guard let user = getCurrentUser else {
            UIAlertController.showMessage(self, msg: "You need to be logged in to favourite a route.")
            faveButton.isSelected = false
            return
        }
        if selected {
            RealmUserSessionManager.default.addToFavourites(route: currentRoute, to: user) { _ in
                UIAlertController.showMessage(self, msg: "Added to favorites!")
            }
        } else {
            RealmUserSessionManager.default.removeFromFavourites(route: currentRoute, from: user, nil)
            UIAlertController.showMessage(self, msg: "Remove from favourites!")
        }
    }
}