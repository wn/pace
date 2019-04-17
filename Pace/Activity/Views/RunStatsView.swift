//
//  UserStatsView.swift
//  Pace
//
//  Created by Tan Zheng Wei on 30/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class RunStatsView: UIView {

    @IBOutlet private var content: UIView!
    @IBOutlet private var totalDistance: UILabel!
    @IBOutlet private var calories: UILabel!
    @IBOutlet private var time: UILabel!
    @IBOutlet private var avgPace: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }

    func setStats(distance: Double, time: Double) {
        totalDistance.text = String(format: "%.2f", distance / 1_000)
        self.time.text = "\(Int(time))"
        calories.text = "\(Int(100 / 1_600 * distance))"
        let pace = distance != 0 ? (time / 60) / (distance / 1_000) : 0
        avgPace.text = String(format: "%.2f", pace)
    }

    private func loadXib() {
        Bundle.main.loadNibNamed(Xibs.runStatsView, owner: self, options: nil)
        addSubview(content)
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
