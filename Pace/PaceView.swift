//
//  PaceView.swift
//  Pace
//
//  Created by Tan Zheng Wei on 26/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class PaceView: UICollectionViewCell {

    @IBOutlet private var content: UIView!
    @IBOutlet private var paceTiming: UILabel!
    @IBOutlet private var paceDistance: UILabel!
    @IBOutlet private var pacePreview: UIImageView!
    @IBOutlet private var paceButton: UIButton!
    private var dateFormat = DateComponentsFormatter()
    weak var delegate: ViewDelegate?
    weak var currentRun: Run?

    var run: Run? {
        get {
            return currentRun
        }
        set(run) {
            currentRun = run
            guard let lastCp = currentRun?.checkpoints.last else {
                return
            }
            paceDistance.text = String(lastCp.routeDistance) + "km"
            paceTiming.text = dateFormat.string(from: lastCp.time)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
        setDateFormat()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
        setDateFormat()
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        guard let runnerPace = currentRun else {
            return
        }
        delegate?.buttonTapped(runnerPace)
    }

    private func setDateFormat() {
        dateFormat.unitsStyle = .brief
        dateFormat.allowedUnits = [.hour, .minute, .second]
    }

    private func loadXib() {
        Bundle.main.loadNibNamed(Xibs.paceView, owner: self, options: nil)
        addSubview(content)
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        pacePreview.backgroundColor = .gray
    }
}
