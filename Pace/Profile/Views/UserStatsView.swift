//
//  UserStatsView.swift
//  Pace
//
//  Created by Tan Zheng Wei on 30/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import RealmSwift

class UserStatsView: UIView {

    @IBOutlet private var content: UIView!
    @IBOutlet private var totalDistance: UILabel!
    @IBOutlet private var totalRuns: UILabel!
    @IBOutlet private var avgDistance: UILabel!
    @IBOutlet private var avgPace: UILabel!
    var runs: Results<Run>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }

    func calculateStats() {
        var totalDist: Double = 0.0
        var totalTime: Double = 0.0
        guard let runs = runs else {
            return
        }
        for run in runs {
            totalDist += run.distance / 1_000
            totalTime += run.timeSpent
        }
        totalDistance.text = String(format: "%.2f",
                                    arguments: [totalDist])
        let averagePace = totalDist != 0 ? totalTime / (60 * totalDist) : 0
        avgPace.text = String(format: "%.2f",
                                arguments: [averagePace])
        avgDistance.text = String(format: "%.2f",
                                  arguments: [!runs.isEmpty ? totalDist / Double(runs.count) : 0])
        totalRuns.text = String(runs.count)
    }

    private func loadXib() {
        Bundle.main.loadNibNamed(Xibs.userStatsView, owner: self, options: nil)
        addSubview(content)
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
