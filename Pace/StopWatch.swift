//
//  StopWatch.swift
//  Pace
//
//  Created by Tan Zheng Wei on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class StopWatch: UIView {

    @IBOutlet private var contentView: UIView!
    @IBOutlet private var timeLabel: UILabel!
    private var dateFormat = DateComponentsFormatter()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setDateFormat()
        loadXib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setDateFormat()
        loadXib()
    }

    private func setDateFormat() {
        dateFormat.unitsStyle = .full
        dateFormat.allowedUnits = [.hour, .minute, .second]
    }

    private func loadXib() {
        Bundle.main.loadNibNamed("StopWatch", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    func setTime(to time: TimeInterval) {
        timeLabel.text = dateFormat.string(from: time)
    }
}
