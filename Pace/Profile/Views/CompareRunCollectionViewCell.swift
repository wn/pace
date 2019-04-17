//
//  CompareRunCollectionViewCell.swift
//  Pace
//
//  Created by Tan Zheng Wei on 9/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class CompareRunCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var content: UIView!
    @IBOutlet private var runDate: UILabel!
    @IBOutlet private var runnerName: UILabel!
    @IBOutlet private var runTime: UILabel!
    @IBOutlet private var tickImage: UIImageView!
    weak var currentRun: Run?

    var run: Run? {
        get {
            return currentRun
        }
        set {
            currentRun = newValue
            guard let currentRun = currentRun else {
                return
            }
            runDate.text = Formatter.formatDate(currentRun.dateCreated)
            runnerName.text = currentRun.runner?.name
            runTime.text = Formatter.formatTime(currentRun.timeSpent)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
        tickImage.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
        tickImage.isHidden = true
    }

    private func loadXib() {
        Bundle.main.loadNibNamed(Xibs.compareRunCollectionViewCell, owner: self, options: nil)
        addSubview(content)
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    func toggleClicked() {
        let oldValue = tickImage.isHidden
        tickImage.isHidden = !oldValue
    }

    override var isSelected: Bool {
        willSet {
            tickImage.isHidden = !isSelected
        }
    }
}
