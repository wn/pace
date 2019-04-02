//
//  StopwatchTimer.swift
//  Pace
//
//  Created by Ang Wei Neng on 25/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class StopwatchTimer {
    var counter = 0.0
    var timer = Timer()
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
        counter = 0.0
    }

    @objc
    func update() {
        counter += 0.1
    }

    func timeElapsed() -> Int {
        return Int(counter)
    }
}
