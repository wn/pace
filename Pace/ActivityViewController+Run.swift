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
        setMapButton(imageUrl: Constants.endButton, action: #selector(endRun(_:)))
        clearMap() // Clear route markers
        VoiceAssistant.say("Starting run")
        coreLocationManager.startUpdatingLocation()
        stopwatch.start()
        updateValues()
    }

    @objc
    func endRun(_ sender: UIButton) {
        guard runStarted else {
            return
        }
        // TODO: TAKE A SCREENSHOT HERE!

        setMapButton(imageUrl: Constants.startButton, action: #selector(startRun(_:)))
        clearMap()

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let summaryVC =
            storyBoard.instantiateViewController(
                withIdentifier: "summaryVC")
                as! ActivitySummaryViewController
        summaryVC.setStats(distance: distance, time: stopwatch.timeElapsed())
        renderChildController(summaryVC)

        VoiceAssistant.say("Run completed")
        stopwatch.reset()
        distance = 0
        coreLocationManager.stopUpdatingLocation()
        updateLabels()
        guard let endPos = lastMarkedPosition?.coordinate else {
            return
        }
        addMarker(Constants.endFlag, position: endPos)
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

    func updateGPS() {
        //        guard let accuracy = coreLocationManager.location?.horizontalAccuracy else {
        //            horizontalAccuracy.text = "Disconnected"
        //            return
        //        }
        //        horizontalAccuracy.text = "Horizontal accuracy: \(accuracy) meters"
    }

    func updateDistanceTravelled() {
        distanceLabel.text = "Distance: \(Int(distance)) metres"
    }

    func updateTimer() {
        self.time.text = "time elapsed: \(self.stopwatch.timeElapsed()) secs"
    }

    func updatePace() {
        let paceValue = distance != 0 ? 1_000 * stopwatch.timeElapsed() / Int(distance) : 0
        pace.text = "Pace: \(paceValue) seconds /km"
    }

    func updateLabels() {
        updatePace()
        updateTimer()
        updateDistanceTravelled()
    }
}
