//
//  PaceView.swift
//  Pace
//
//  Created by Tan Zheng Wei on 26/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class RunCollectionViewCell: UICollectionViewCell {

    @IBOutlet private var content: UIView!
    @IBOutlet private var runDate: UILabel!
    @IBOutlet private var runTiming: UILabel!
    @IBOutlet private var runDistance: UILabel!
    @IBOutlet private var thumbnail: UIImageView!
    weak var currentRun: Run?

    var run: Run? {
        get {
            return currentRun
        }
        set(run) {
            currentRun = run
            guard let currentRun = currentRun else {
                return
            }
            runDate.text = Formatter.formatDate(currentRun.dateCreated)
            runDistance.text = String(currentRun.distance) + "km"
            runTiming.text = Formatter.formatTime(currentRun.timeSpent)
            thumbnail.image = currentRun.thumbnail
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }

    private func loadXib() {
        Bundle.main.loadNibNamed(Xibs.runCollectionViewCell, owner: self, options: nil)
        addSubview(content)
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
