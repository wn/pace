//
//  Pace.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

class Pace {
    private let runner: User
    private var checkPoints: [CheckPoint]

    init(runner: User, checkPoints: [CheckPoint]) {
        self.runner = runner
        self.checkPoints = checkPoints
    }
}
