//
//  RunGraphView.swift
//  Pace
//
//  Created by Tan Zheng Wei on 5/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import CoreLocation

enum GraphComparisonMode {
    case speed
}

class RunGraphView: UIView {

    @IBOutlet private var content: UIView!
    @IBOutlet private var graphArea: UIView!
    @IBOutlet private var yLine: UIView!
    @IBOutlet private var yLineWidthConstraint: NSLayoutConstraint!
    @IBOutlet private var label: UILabel!
    @IBOutlet private var labelYCoordConstraint: NSLayoutConstraint!

    private var drawContext: CGContext?
    private var comparisonMode: GraphComparisonMode = .speed
    private var upperBound: Double?

    var currentRun: Run?
    var compareRun: Run?

    override func draw(_ rect: CGRect) {
        let drawContext = UIGraphicsGetCurrentContext()
        guard let currentRun = currentRun else {
            return
        }
        draw(run: currentRun, with: drawContext)
        guard let compareRun = compareRun else {
            return
        }
        draw(run: compareRun, with: drawContext)
        super.draw(rect)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
        self.layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
        self.layer.masksToBounds = true
    }

    /// Compares two checkpoints based on the comparison mode of the graph
    private func compare(_ cp1: CheckPoint, _ cp2: CheckPoint) -> Bool {
        switch comparisonMode {
        case .speed:
            return (cp1.location?.speed ?? 0) < (cp2.location?.speed ?? 0)
        }
    }

    /// Returns a property of the CLLocation representing the mode of the graph
    private func resolveModeValue(_ location: CLLocation?) -> Double {
        switch comparisonMode {
        case .speed:
            return location?.speed ?? 0
        }
    }

    private func draw(run: Run, with drawContext: CGContext?) {
        // Sets up the upperbound y-value
        let maxCp = run.checkpoints.max(by: { cp1, cp2 -> Bool in
            return compare(cp1, cp2)
        })
        let maxY = resolveModeValue(maxCp?.location)
        upperBound = maxY * 8 / 7
        // Draws the run based on the upperbound
        guard let drawContext = drawContext else {
            return
        }
        var iterator = run.checkpoints.makeIterator()
        drawContext.setLineJoin(.round)
        drawContext.setLineWidth(2.0)
        drawContext.setStrokeColor(UIColor.blue.cgColor)

        var leftCp = iterator.next()
        var rightCp = iterator.next()
        while leftCp != nil && rightCp != nil {
            let leftPoint = translate(leftCp, in: run)
            let rightPoint = translate(rightCp, in: run)
            drawContext.move(to: leftPoint)
            drawContext.addLine(to: rightPoint)
            leftCp = rightCp
            rightCp = iterator.next()
        }
        drawContext.strokePath()
    }

    /// Translates a checkpoint into a CGPoint on the graph
    private func translate(_ checkpoint: CheckPoint?, in run: Run) -> CGPoint {
        guard let checkpoint = checkpoint,
            let upperBound = upperBound else {
            return CGPoint()
        }
        let xVal = graphArea.frame.width * CGFloat(checkpoint.routeDistance / run.distance)
        let yVal = graphArea.frame.height - graphArea.frame.height * CGFloat(resolveModeValue(checkpoint.location) / upperBound)
        return CGPoint(x: xVal, y: yVal)
    }

    private func loadXib() {
        Bundle.main.loadNibNamed(Xibs.runGraphView, owner: self, options: nil)
        addSubview(content)
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    /// Removes the width constraint from the yLine and moves creates a new constraint
    /// based on the new x-multiplier (of the width)
    func moveYLine(to xMultiplier: CGFloat, location: CLLocation) {
        let newYLineConstraint =
            NSLayoutConstraint(item: yLineWidthConstraint.firstItem as Any,
                               attribute: yLineWidthConstraint.firstAttribute,
                               relatedBy: yLineWidthConstraint.relation,
                               toItem: yLineWidthConstraint.secondItem,
                               attribute: yLineWidthConstraint.secondAttribute,
                               multiplier: xMultiplier,
                               constant: yLineWidthConstraint.constant)
        content.removeConstraint(yLineWidthConstraint)
        yLineWidthConstraint = newYLineConstraint
        content.addConstraint(newYLineConstraint)

        // Render intersection label
        guard let run = currentRun,
            let upperBound = upperBound else {
            return
        }
        // Distance - Rounded to 2 d.p
        let xValue = Double(100 * round(Double(xMultiplier) * run.distance / 1_000))
        let yValue = resolveModeValue(location)
        let labelText = String(xValue) + "km, " + String(100 * round(yValue / 100)) + "m"
        label.text = labelText
        let yHeight = graphArea.frame.height - graphArea.frame.height * CGFloat(yValue / upperBound)
        let newLabelConstraint =
            NSLayoutConstraint(item: labelYCoordConstraint.firstItem as Any,
                               attribute: labelYCoordConstraint.firstAttribute,
                               relatedBy: labelYCoordConstraint.relation,
                               toItem: labelYCoordConstraint.secondItem,
                               attribute: labelYCoordConstraint.secondAttribute,
                               multiplier: labelYCoordConstraint.multiplier,
                               constant: -20 + yHeight)
        content.removeConstraint(labelYCoordConstraint)
        labelYCoordConstraint = newLabelConstraint
        content.addConstraint(newLabelConstraint)
    }
}
