//
//  ActivitySummaryViewController.swift
//  Pace
//
//  Created by Ang Wei Neng on 25/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import CoreLocation

class ActivitySummaryViewController: UIViewController {
    @IBOutlet private var distanceLabel: UILabel!
    @IBOutlet private var paceLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!

    var distance: Double = 0
    var pace: Int = 0
    var time: Double = 0

    func setStats(distance: CLLocationDistance, time: Double) {
        self.distance = distance
        self.pace = distance == 0 ? 0 : Int(time / distance)
        self.time = time
    }

    override func viewDidLoad() {
        distanceLabel.text = "distance: \(distance) meters"
        paceLabel.text = "pace: \(pace)"
        timeLabel.text = "time: \(time) seconds"
        VoiceAssistant.say("Distance: \(distance) meters")
        VoiceAssistant.say("Duration: \(time) seconds")
        VoiceAssistant.say("Pace: \(pace) seconds per kilometer")
    }

    @IBAction private func exit(_ sender: UIButton) {
        derenderChildController()
    }
}
