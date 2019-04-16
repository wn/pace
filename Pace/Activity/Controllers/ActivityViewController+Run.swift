//
//  ActivityViewController+Run.swift
//  Pace
//
//  Created by Ang Wei Neng on 3/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

// MARK: - Running methods
extension ActivityViewController {
    @objc
    func startRun(_ sender: UIButton) {
        guard !runStarted else {
            return
        }
        setMapButton(imageUrl: Constants.endButton, action: #selector(endRun(_:)))
        startingRun()
    }

    func startingRun() {
        guard let startLocation = coreLocationManager.location else {
            fatalError("Should have location here.")
        }
        initiateRunPlot(at: startLocation)
        startNewRunSession(at: startLocation)
        updateValues()
    }

    func startingFollowRun(with paceRun: Run) {
        guard let startingLocation = coreLocationManager.location,
            let paceRunStart = paceRun.startingLocation else {
                fatalError("Should have location here.")
        }
        // TODO: draw the paceRun on map
        guard startingLocation.isSameAs(other: paceRunStart) else {
            // TODO: show on UI to tell user to move closer
            return
        }
        initiateRunPlot(at: startingLocation)
        startFollowRunSession(at: startingLocation, following: paceRun)
        updateValues()
    }

    private func initiateRunPlot(at location: CLLocation) {
        googleMapView.startRun(at: location.coordinate)
    }

    private func startNewRunSession(at location: CLLocation) {
        VoiceAssistant.say("Starting new run")
        coreLocationManager.startUpdatingLocation()
        stopwatch.start()
        // TODO: allow user to run without signing in
        ongoingRun = OngoingRun(runner: Dummy.user, startingLocation: location)
    }

    private func startFollowRunSession(at location: CLLocation, following paceRun: Run) {
        VoiceAssistant.say("Starting follow run")
        coreLocationManager.startUpdatingLocation()
        stopwatch.start()
        ongoingRun = OngoingRun(runner: Dummy.follower, startingLocation: location, paceRun: paceRun)
        stopwatch.startMonitoringPace(from: self)
    }

    @objc
    func reflectPacingStats() {
        VoiceAssistant.reportPacing(using: ongoingRun?.getPacingStats())
    }

    @objc
    func endRun(_ sender: UIButton) {
        guard runStarted else {
            return
        }
        VoiceAssistant.say("Run completed")

        // TODO: ALL OUR ENDRUN LOGIC SHOULD BE DONE HERE
        // 1. Start loading animation
        // 2. Perform normalisation shit here
        // 3. Add end flag
        // 4. Rerender the normalized-map and take a screenshot
        // 5. Show the map in the summary page. Cannot just be screenshot
        //    because of runAnalysis.
        // 6. When we press "exit summary", clean up flag drawings.
        googleMapView.addMarker(Constants.endFlag, position: coreLocationManager.location!.coordinate)
        googleMapView.completeRun()

        setMapButton(imageUrl: Constants.startButton, action: #selector(startRun(_:)))

        showSummary()

        ongoingRun = nil
        stopwatch.reset()
        stopwatch.stopMonitoringPace()
        coreLocationManager.stopUpdatingLocation()
        updateLabels()
    }

    func showSummary() {
        let storyBoard: UIStoryboard = UIStoryboard(name: Identifiers.storyboard, bundle: nil)
        let summaryVC =
            storyBoard.instantiateViewController(
                withIdentifier: Identifiers.summaryViewController)
                as! ActivitySummaryViewController
        summaryVC.setRun(as: ongoingRun)
        self.navigationController?.pushViewController(summaryVC, animated: true)
    }

    func updateValues() {
        guard runStarted else {
            return
        }
        updateLabels()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateValues()
        }
    }

    func updateLabels() {
        guard let distanceSoFar = ongoingRun?.distanceSoFar else {
            return
        }
        runStats.setStats(distance: distanceSoFar, time: stopwatch.timeElapsed)
    }
}
