//
//  RunGraphView.swift
//  Pace
//
//  Created by Tan Zheng Wei on 5/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import CoreLocation

enum GraphComparisonMode: String, CaseIterable {
    case speed, altitude, timeSpent
}

class RunGraphView: UIView {

    @IBOutlet private var content: UIView!
    @IBOutlet private var graphArea: UIView!
    @IBOutlet private var yLine: UIView!
    @IBOutlet private var yLineWidthConstraint: NSLayoutConstraint!
    @IBOutlet private var higherLabel: UILabel!
    @IBOutlet private var lowerLabel: UILabel!

    private var drawContext: CGContext?
    private var comparisonMode: GraphComparisonMode = .speed
    private var upperBound: Double?

    var currentRun: Run?
    var compareRun: Run?

    var currentRunColor: UIColor {
        return .blue
    }

    var compareRunColor: UIColor {
        return .red
    }

    var mode: GraphComparisonMode {
        get {
            return comparisonMode
        }
        set {
            comparisonMode = newValue
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        let drawContext = UIGraphicsGetCurrentContext()
        setUpperBound()
        draw(run: currentRun, color: currentRunColor, with: drawContext)
        draw(run: compareRun, color: compareRunColor, with: drawContext)
        lowerLabel.text = nil
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

    var maxDistance: Double {
        return max(currentRun?.distance ?? 0, compareRun?.distance ?? 0)
    }

    /// Compares two checkpoints based on the comparison mode of the graph
    private func compare(_ cp1: CheckPoint, _ cp2: CheckPoint) -> Bool {
        switch comparisonMode {
        case .speed:
            return (cp1.location?.speed ?? 0) < (cp2.location?.speed ?? 0)
        case .altitude:
            return (cp1.location?.altitude ?? 0) < (cp2.location?.altitude ?? 0)
        case .timeSpent:
            return cp1.time < cp2.time
        }
    }

    /// Returns a property of a Checkpoint representing the mode of the graph
    private func resolveModeValue(_ checkpoint: CheckPoint?) -> Double {
        switch comparisonMode {
        case .speed:
            return checkpoint?.location?.speed ?? 0
        case .altitude:
            return checkpoint?.location?.altitude ?? 0
        case .timeSpent:
            return checkpoint?.time ?? 0
        }
    }

    /// Based on the currentRun and compareRun, sets an upperbound that bounds the checkpoints for both runs
    /// The upperBound is the maximum y-value of the graph
    /// which is set to 8/7 of the highest value of either graph
    private func setUpperBound() {
        // Sets up the upperbound y-value
        let maxCp1 = currentRun?.checkpoints.max(by: { cp1, cp2 -> Bool in
            return compare(cp1, cp2)
        })
        let maxY1 = resolveModeValue(maxCp1)
        let maxCp2 = compareRun?.checkpoints.max(by: { cp1, cp2 -> Bool in
            return compare(cp1, cp2)
        })
        let maxY2 = resolveModeValue(maxCp2)
        upperBound = max(maxY1, maxY2) * 8 / 7
    }

    private func draw(run: Run?, color: UIColor, with drawContext: CGContext?) {
        // Draws the run based on the upperbound
        guard let run = run,
            let drawContext = drawContext else {
            return
        }
        var iterator = run.checkpoints.makeIterator()
        drawContext.setLineJoin(.round)
        drawContext.setLineWidth(2.0)
        drawContext.setAlpha(0.7)
        drawContext.setLineCap(.round)
        drawContext.setStrokeColor(color.cgColor)

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
        let xVal = graphArea.frame.width * CGFloat(checkpoint.routeDistance / maxDistance)
        let yVal = graphArea.frame.height - graphArea.frame.height * CGFloat(resolveModeValue(checkpoint) / upperBound)
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
    /// - Parameter xMultiplier: percentage of the width of the graph
    /// - Parameter currentCheckpoint: (interpolated) checkpoint of the current run
    /// - Parameter compareCheckpoint: (interpolated) checkpoint of the run being compared
    func moveYLine(to xMultiplier: CGFloat, currentCheckpoint: CheckPoint, compareCheckpoint: CheckPoint?) {
        let newYLineConstraint = yLineWidthConstraint.replace(newMultiplier: xMultiplier)
        content.removeConstraint(yLineWidthConstraint)
        yLineWidthConstraint = newYLineConstraint
        content.addConstraint(newYLineConstraint)

        // Render and move intersection label
        let xCurrentValue = currentCheckpoint.routeDistance / 1_000
        let yCurrentValue = resolveModeValue(currentCheckpoint)
        let currentLabelText = generateLabel(x: xCurrentValue, y: yCurrentValue)
        guard let compareCheckpoint = compareCheckpoint else {
            lowerLabel.text = currentLabelText
            lowerLabel.textColor = currentRunColor
            higherLabel.text = nil
            return
        }
        let xCompareValue = compareCheckpoint.routeDistance / 1_000
        let yCompareValue = resolveModeValue(compareCheckpoint)
        let compareLabelText = generateLabel(x: xCompareValue, y: yCompareValue)

        if yCompareValue > yCurrentValue {
            lowerLabel.text = currentLabelText
            lowerLabel.textColor = currentRunColor
            higherLabel.text = compareLabelText
            higherLabel.textColor = compareRunColor
        } else {
            higherLabel.text = currentLabelText
            higherLabel.textColor = currentRunColor
            lowerLabel.text = compareLabelText
            lowerLabel.textColor = compareRunColor
        }
    }

    private func generateLabel(x: Double, y: Double) -> String {
        let yMetric: String
        switch comparisonMode {
        case .speed:
            yMetric = "m/s"
        case .altitude:
            yMetric = "m"
        case .timeSpent:
            yMetric = "min"
        }
        return String(format: "%.2fkm, %.2f\(yMetric)", arguments: [x, y])
    }
}
