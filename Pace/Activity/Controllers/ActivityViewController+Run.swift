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
        startingRun()
    }

    func startingRun() {
        guard let startLocation = coreLocationManager.location else {
            fatalError("Should have location here.")
        }
        initiateRunPlot(at: startLocation)
        startRunningSession(at: startLocation)
        // TODO: update running stats here
        updateValues()
    }

    private func initiateRunPlot(at location: CLLocation) {
        setMapButton(imageUrl: Constants.endButton, action: #selector(endRun(_:)))
        googleMapView.startRun(at: location.coordinate)
    }

    private func startRunningSession(at location: CLLocation) {
        VoiceAssistant.say("Starting run")
        coreLocationManager.startUpdatingLocation()
        stopwatch.start()
        // TODO: add follow run
        // TODO: allow user to run without signing in
        ongoingRun = OngoingRun(runner: userSession.getRealmUser(nil)!, startingLocation: location)
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
        coreLocationManager.stopUpdatingLocation()
        updateLabels()
    }

    func showSummary() {
        guard let ongoingRun = ongoingRun else {
                return
        }
        let storyBoard: UIStoryboard = UIStoryboard(name: Identifiers.storyboard, bundle: nil)
        let summaryVC =
            storyBoard.instantiateViewController(
                withIdentifier: Identifiers.summaryViewController)
                as! ActivitySummaryViewController
        summaryVC.setStats(createdRun: ongoingRun, distance: distance, time: stopwatch.timeElapsed)
        renderChildController(summaryVC)
    }

    func updateValues() {
        guard runStarted else {
            return
        }
        updateLabels()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateValues()
        }
    }

    func updateLabels() {
        updatePace()
        updateTimer()
        updateDistanceTravelled()
    }
}
