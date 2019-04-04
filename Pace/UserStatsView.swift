//
//  UserStatsView.swift
//  Pace
//
//  Created by Tan Zheng Wei on 30/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class UserStatsView: UIView {

    @IBOutlet private var content: UIView!
    @IBOutlet private var totalDistance: UILabel!
    @IBOutlet private var totalRuns: UILabel!
    @IBOutlet private var avgDistance: UILabel!
    @IBOutlet private var avgPace: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }

    func setStats(with user: User) {

    }

    private func loadXib() {
        Bundle.main.loadNibNamed(Xibs.userStatsView, owner: self, options: nil)
        addSubview(content)
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
