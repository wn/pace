//
//  Pace.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

class Run: IdentifiableObject {
    @objc dynamic var runner: User?
    @objc dynamic var dateCreated = Date()
    @objc dynamic var timeSpent: Double = 0.0
    var checkpoints = List<CheckPoint>()

    // TODO: test map and compactMap for Realm List
    var locations: [CLLocation] {
        return checkpoints.compactMap { $0.location }
    }

    convenience init(runner: User, checkpoints: [CheckPoint]) {
        self.init()
        guard let lastPoint = checkpoints.last else {
            return
        }
        self.runner = runner
        self.timeSpent = lastPoint.time
        self.checkpoints = {
            let checkpointsList = List<CheckPoint>()
            checkpointsList.append(objectsIn: checkpoints)
            return checkpointsList
        }()
    }

    /// Normalizes an array of CheckPoints based on the checkPoints array of this Pace.
    /// - Precondition: the given runner record does not deviate from this Pace.
    /// - Parameter runnerRecords: the array of CheckPoints to be normalized.
    /// - Returns: an array of normalized CheckPoints.
    func normalize(_ runnerRecords: [CheckPoint]) -> [CheckPoint] {
        return checkpoints.map { basePoint in
            basePoint.extractNormalizedPoint(from: runnerRecords)
        }
    }
}
