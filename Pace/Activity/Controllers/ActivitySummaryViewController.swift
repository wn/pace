//
//  ActivitySummaryViewController.swift
//  Pace
//
//  Created by Ang Wei Neng on 25/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import CoreLocation
import FacebookLogin
import FacebookCore

class ActivitySummaryViewController: UIViewController {
    // MARK: UI variables
    @IBOutlet private var statsView: RunStatsView!

    // MARK: Run variables
    private var finishedRun: OngoingRun?
    private var finishedRoute: Route?
    private var routesManager = CachingStorageManager.default
    private var runStateManager = RealmRunStateManager.default
    private var isSaved = false

    /// Set the necessary information for the summary. Called when initializing the summary.
    func setRun(as finishedRun: OngoingRun?) {
        self.finishedRun = finishedRun
        finishedRoute = finishedRun?.toNewRoute()
    }

    var currentUser: User? {
        guard let uid = AccessToken.current?.userId else {
            return nil
        }
        return RealmUserSessionManager.default.getRealmUser(uid)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Titles.runSummary
        statsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(analyse)))
        setupSaveButton()
        showStats()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let currentUser = currentUser else {
            return
        }
        finishedRun?.runner = currentUser
        finishedRoute?.creator = UserReference(fromUser: currentUser)
    }
    @objc
    func analyse(_ sender: UIButton) {
        showRunAnalysis(finishedRoute?.creatorRun, finishedRun?.paceRun)
    }

    func showRunAnalysis(_ firstRun: Run?, _ secondRun: Run? = nil) {
        guard let runAnalysis = UIStoryboard(name: Identifiers.storyboard, bundle: nil)
            .instantiateViewController(withIdentifier: Identifiers.runAnalysisController)
            as? RunAnalysisController else {
                return
        }
        runAnalysis.run = firstRun
        runAnalysis.compareRun = secondRun
        navigationController?.pushViewController(runAnalysis, animated: true)
    }

    private func setupSaveButton() {
        let saveButton = SaveButton()
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        saveButton.awakeFromNib()
    }

    @objc
    private func saveButtonPressed() {
        guard !isSaved else {

            return
        }
        // Guard against user whom are not logged i
        guard currentUser != nil else {
            UIAlertController.showMessage(
                self,
                msg: "You need to be logged in to save your progress.")
            runStateManager.clearRunState()
            return
        }

        guard let distance = finishedRun?.distanceSoFar,
            distance >= Constants.checkPointDistanceInterval else {
            // Distance of the run is not long enough for saving
            UIAlertController.showMessage(self, msg: "Distance covered is insufficient to be saved.")
            runStateManager.clearRunState()
            return
        }

        let followingRun = finishedRun?.paceRun?.routeId != nil
        var message = ""
        if followingRun {
            if finishedRun?.classifiedAsFollow() ?? false {
                message = "Would you like to create a new route or add your run to this route?"
            } else {
                message = "Unable to add your run statistics to this route as you deviated "
                    + "from the suggested route too drastically."
            }
        } else {
            message = "Would you like to share the route to public?"
        }
        let alert = UIAlertController(
            title: "Save run",
            message: message,
            preferredStyle: .alert)
        if followingRun, (finishedRun?.classifiedAsFollow() ?? false) {
            alert.addAction(UIAlertAction(title: "Add my run", style: .default) { [unowned self] _ in
                self.saveFollowRun()
            })
        }
        alert.addAction(UIAlertAction(title: "Create new route", style: .default) { [unowned self] _ in
            self.saveRun()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    private func saveRun() {
        guard let finishedRun = finishedRun,
            let newRoute = finishedRun.toNewRoute() else {
            // run was not set up properly when initializing this VC
            UIAlertController.showMessage(self, msg: "There is an error saving your route. Please try again later.")
            return
        }

        // Ensure that any persisted states are removed once the new route is created
        runStateManager.clearRunState()

        routesManager.saveNewRoute(newRoute) {[unowned self] _ in
            self.isSaved = true
            UIAlertController.showMessage(self, msg: "Saved new route")
        }
    }

    func saveFollowRun() {
        guard let finishedRun = finishedRun,
            let parentRouteId = finishedRun.paceRun?.routeId,
            let parentRoute = finishedRun.paceRun?.route else {
            runStateManager.clearRunState()
            return
        }

        if finishedRun.classifiedAsFollow() { // save to the parent
            guard let run = finishedRun.toRun(parentRouteId) else {
                return
            }
            routesManager.saveNewRun(run, toRoute: parentRoute) { [unowned self] _ in
                self.isSaved = true
                UIAlertController.showMessage(self, msg: "Added your statistics to the followed route.")
            }
        }
    }

    private func showStats() {
        guard let distance = finishedRun?.distanceSoFar, let time = finishedRun?.timeSoFar else {
            return
        }
        statsView.setStats(distance: distance, time: time)
    }
}
