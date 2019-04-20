//
//  ActivityViewController+PersistRunStateController.swift
//  Pace
//
//  Created by Tan Zheng Wei on 20/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation

protocol PersistRunStateDelegate {
    func generateRunState() -> RunState?
}

class RunState: Object {
    @objc dynamic var ongoingRun: OngoingRun?
    @objc dynamic var timeStarted = Date()
    @objc dynamic var timeInterrupted = Date()
    @objc dynamic var offset = 0.0

    convenience init(ongoingRun: OngoingRun, timeStarted: Date, timeInterrupted: Date, offset: Double) {
        self.init()
        self.ongoingRun = ongoingRun
        self.timeStarted = timeStarted
        self.timeInterrupted = timeInterrupted
        self.offset = offset
    }
}

extension ActivityViewController: PersistRunStateDelegate {
    func generateRunState() -> RunState? {
        guard stopwatch.isPlaying,
            let ongoingRun = ongoingRun,
            let timeStarted = stopwatch.timeStarted else {
            return nil
        }

        return RunState(ongoingRun: ongoingRun,
                        timeStarted: timeStarted,
                        timeInterrupted: Date(),
                        offset: stopwatch.offset)
    }

    func setupPersistDelegate() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.persistRunStateDelegate = self
    }

    func checkForPersistedState() {
        guard let persistedState = Realm.cache.objects(RunState.self).first else {
            return
        }
        // Load the persistedState
        guard let persistedRun = persistedState.ongoingRun else {
            return
        }

        // TODO: Delete from cache

        resumeRun(run: persistedRun,
                  startedAt: persistedState.timeStarted,
                  interruptedAt: persistedState.timeInterrupted,
                  persistedOffset: persistedState.offset)
    }
}
