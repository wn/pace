//
//  StopwatchTimer.swift
//  Pace
//
//  Created by Ang Wei Neng on 25/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class StopwatchTimer {
    var offset = 0.0
    var timeStarted: Date?
    var timeElapsed = 0.0
    var timer = Timer()
    var isPlaying = false

    func resume(with offset: Double) {
        self.offset = offset
        timeStarted = Date()
        schedule()
        isPlaying = true
    }

    func start() {
        if isPlaying {
            return
        }
        timeStarted = Date()
        schedule()
        isPlaying = true
    }

    private func schedule() {
        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(update),
            userInfo: nil,
            repeats: true)
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
        offset = 0.0
    }

    @objc
    func update() {
        guard let timeStarted = timeStarted else {
            return
        }
        timeElapsed = Date().timeIntervalSince(timeStarted) + offset
    }
}
