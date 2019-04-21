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

class RouteDrawerViewController: PullUpController {
    var userSession: UserSessionManager?
    var initialState: InitialState = .expanded

    var showingRoutes: [Route] = []
    var viewingRouteIndexValue: Int?
    var viewingRouteIndex: Int? {
        get {
            return viewingRouteIndexValue
        }
        set {
            guard !showingRoutes.isEmpty,
                let val = newValue else {
                    viewingRouteIndexValue = nil
                    return
            }
            let currIndex = (val + showingRoutes.count) % showingRoutes.count
            viewingRouteIndexValue = currIndex
            if viewingRouteIndexValue == 0 {
                prevRoute.isEnabled = false
                prevRoute.setTitle("<", for: .disabled)
            } else {
                prevRoute.isEnabled = true
                prevRoute.setTitle("\(currIndex) <", for: .normal)
            }
            if viewingRouteIndexValue == showingRoutes.count - 1 {
                rightRoute.isEnabled = false
                rightRoute.setTitle(">", for: .disabled)
            } else {
                rightRoute.isEnabled = true
                rightRoute.setTitle("> \(showingRoutes.count - currIndex - 1)", for: .normal)
            }
            renderRouteStats()
        }
    }

    @IBOutlet var prevRoute: UIButton!
    @IBOutlet var rightRoute: UIButton!

    var getCurrentUser: User? {
        guard let uid = AccessToken.current?.userId else {
            return nil
        }
        return RealmUserSessionManager.default.getRealmUser(uid)
    }

    var paces: [Run] = []
    let runnerCellIdentifier = "runnerCell"

    enum InitialState {
        case contracted
        case expanded
    }
    @IBAction func rightRoute(_ sender: UIButton) {
        guard let currentIndex = viewingRouteIndex else {
            return
        }
        viewingRouteIndex = currentIndex + 1
    }
    @IBAction func leftRoute(_ sender: UIButton) {
        guard let currentIndex = viewingRouteIndex else {
            return
        }
        viewingRouteIndex = currentIndex - 1
    }

    // MARK: - IBOutlets
    @IBOutlet private var favouriteButton: FaveButton!
    @IBOutlet private var numOfRunners: UILabel!
    @IBOutlet private var startPoint: UILabel!
    @IBOutlet private var endPoint: UILabel!
    @IBOutlet private var createdBy: UILabel!
    @IBOutlet private var distance: UILabel!
    @IBOutlet private var runnersTableView: UITableView!
    @IBOutlet private weak var visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var routeStatsContainerView: UIView!
    @IBOutlet private weak var expandedView: UIView!
    @IBOutlet private weak var searchSeparatorView: UIView! {
        didSet {
            searchSeparatorView.layer.cornerRadius = searchSeparatorView.frame.height / 2
        }
    }
    @IBAction func follow(_ sender: UIButton) {
        guard let run = getViewingRoute?.creatorRun else {
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
        favouriteButton.delegate = self
        routeStatsContainerView.bringSubviewToFront(favouriteButton)
    }

    override func pullUpControllerWillMove(to stickyPoint: CGFloat) {
    }

    override func pullUpControllerDidMove(to stickyPoint: CGFloat) {
        if stickyPoint == 0 {
            closeDrawer()
        }
    }

    func closeDrawer() {
        parent?.removePullUpController(self, animated: true)
    }

    override func pullUpControllerDidDrag(to point: CGFloat) {
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

extension RouteDrawerViewController {
    func setupDrawer(_ routes: Set<Route>) {
        showingRoutes = Array(routes)
        viewingRouteIndex = 0
    }

    var getViewingRoute: Route? {
        guard !showingRoutes.isEmpty,
            let viewingRouteIndex = viewingRouteIndex else {
                return nil
        }
        return showingRoutes[viewingRouteIndex]
    }

    private func renderRoute() {
        guard let route = getViewingRoute,
            let delegate = (parent as? ActivityViewController) else {
                return
        }
        delegate.renderRoute(route)
    }

    func renderRouteStats() {
        guard let route = getViewingRoute,
            let stats = route.generateStats() else {
            return
        }
        stats.startingLocation.address { [weak self] address in
            self?.startPoint.text = "Start: \(address ?? "Unknown")"
        }
        stats.endingLocation.address { [weak self] address in
            self?.endPoint.text = "End: \(address ?? "Unknown")"
        }
        createdBy.text = "Created by: \(route.creator?.name ?? "")"
        distance.text = String(format: "Distance: %.2fkm", arguments: [stats.totalDistance / 1_000])
        paces = route.paces.sorted { $0.timeSpent < $1.timeSpent }
        numOfRunners.text = "\(paces.count) 🏃🏻‍♂️"

        runnersTableView.reloadData()
        // Set favourite flag
        let isFavourite = getCurrentUser?.isFavouriteRoute(route) ?? false
        favouriteButton.setSelected(selected: isFavourite, animated: false)
        renderRoute()
    }
}

/// MARK: - Runner's table configuration
extension RouteDrawerViewController: UITableViewDataSource, UITableViewDelegate {
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

extension RouteDrawerViewController: FaveButtonDelegate {
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool) {
        guard let currentRoute = getViewingRoute else {
            faveButton.isSelected = false
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
