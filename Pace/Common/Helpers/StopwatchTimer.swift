//
//  StopwatchTimer.swift
//  Pace
//
//  Created by Ang Wei Neng on 25/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class StopwatchTimer {
    var timeElapsed = 0.0
    var timer = Timer()
    var paceTimer = Timer()
    var isPlaying = false

    func start() {
        if isPlaying {
            return
        }

        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(update),
            userInfo: nil,
            repeats: true)
        isPlaying = true
    }

    func pause() {
        timer.invalidate()
        isPlaying = false
    }

    func reset() {
        timer.invalidate()
        isPlaying = false
        timeElapsed = 0.0
    }

    @objc
    func update() {
        timeElapsed += 0.1
    }

    func startMonitoringPace() {
        paceTimer = Timer.scheduledTimer(
            timeInterval: 10,
            target: self,
            selector: #selector(ActivityViewController.reflectPacingStats),
            userInfo: nil,
            repeats: true)
    }

    func stopMonitoringPace() {
        paceTimer.invalidate()
    }
}
