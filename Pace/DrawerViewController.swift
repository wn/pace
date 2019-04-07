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
    @IBOutlet var favouriteButton: FaveButton!
    @IBOutlet var numOfRunners: UILabel!
    var initialState: InitialState = .expanded

    @IBOutlet var startPoint: UILabel!
    @IBOutlet var endPoint: UILabel!
    @IBOutlet var createdBy: UILabel!
    @IBOutlet var distance: UILabel!


    var viewingRoute: Route? = nil

    @IBOutlet var runnersTableView: UITableView!
    var paces = List<Run>()
    let runnerCellIdentifier = "runnerCell"

    enum InitialState {
        case contracted
        case expanded
    }

    func routeStats(/*route: Route*/) {
        //label.text = stat
        /*
         number of runners
         distance
         start point
         end point
         created by
         add_to_favourite
         */

//        guard let stats = route.generateStats() else {
//            return
//        }
//        viewingRoute = route
//        paces = route.paces
//
//        startPoint.text = "START: \(stats.startingLocation)"
//        endPoint.text = "END: \(stats.endingLocation)"
//        createdBy.text = "Created by: \(route.creator?.name ?? ""))"
//        distance.text = "Distance: \(stats.totalDistance)"


        // IF ROUTES IN FAVOURITE: SET SELECTED TO TRUE
        favouriteButton.setSelected(selected: true, animated: false)
        numOfRunners.text = "\(paces.count) 🏃🏻‍♂️"

        // Add tap gesture to drawer
        routeStatsContainerView.gestureRecognizers?.removeAll()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(startRoute(_:)))
        routeStatsContainerView.addGestureRecognizer(tapGesture)
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

extension DrawerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paces.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: runnerCellIdentifier, for: indexPath) as! RunnerTableViewCell
        let row = indexPath.row
        cell.setupCell(pos: row + 1, name: "John Tan", time: 100 * row)
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
        switch selected {
        case true:
            print("SELECTED BUTTON: ADD TO FAVOURITE")
        case false:
            print("DELECTED BUTTON: REMOVE FROM FAVOURITE")
        }
    }
}
