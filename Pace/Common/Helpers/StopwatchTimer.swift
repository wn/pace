//
//  StopwatchTimer.swift
//  Pace
//
//  Created by Ang Wei Neng on 25/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class StopwatchTimer {
    var timeStarted: Date?
    var timeElapsed = 0.0
    var timer = Timer()
    var isPlaying = false

    func start() {
        if isPlaying {
            return
        }
        timeStarted = Date()
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
        timeStarted = nil
    }

    @objc
    func update() {
        guard let timeStarted = timeStarted else {
            return
        }
        timeElapsed = Date().timeIntervalSince(timeStarted)
    }
}
