//
//  SignalStrengthIndicator.swift
//  SignalStrengthIndicator
//
//  Created by Maxim on 1/22/18.
//  Copyright © 2018 maximbilan. All rights reserved.
//
import UIKit
import CoreLocation

public class GpsStrengthIndicator: UIView {
    // MARK: - Customization

    public var edgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
    public var spacing: CGFloat = 3
    public var color = UIColor.white

    // MARK: - Constants
    private let indicatorsCount: Int = 5

    // MARK: - GPS Strength
    private var _level = Level.noSignal
    // TODO: Fix this shit code some day
    public func setStrength(_ accuracy: CLLocationAccuracy) {
        if accuracy < 0 {
            _level = .noSignal
        } else if accuracy < 15 {
            _level = .excellent
        } else if accuracy < 25 {
            _level = .good
        } else if accuracy < 30 {
            _level = .low
        } else {
            _level = .veryLow
        }
        setNeedsDisplay()
    }

    // MARK: - Drawing

    override public func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }

        ctx.saveGState()

        let levelValue = _level.rawValue

        let barsCount = CGFloat(indicatorsCount)
        let barWidth = (rect.width - edgeInsets.right - edgeInsets.left - ((barsCount - 1) * spacing)) / barsCount
        let barHeight = rect.height - edgeInsets.top - edgeInsets.bottom

        for index in 0...indicatorsCount - 1 {
            let CGFloatIndex = CGFloat(index)
            let width = barWidth
            let height = barHeight - (((barHeight * 0.5) / barsCount) * (barsCount - CGFloatIndex))
            let xPos: CGFloat = edgeInsets.left + CGFloatIndex * barWidth + CGFloatIndex * spacing
            let yPos: CGFloat = barHeight - height
            let cornerRadius: CGFloat = barWidth * 0.25
            let barRect = CGRect(x: xPos, y: yPos, width: width, height: height)
            let clipPath: CGPath = UIBezierPath(roundedRect: barRect, cornerRadius: cornerRadius).cgPath

            ctx.addPath(clipPath)

            if index + 1 > levelValue {
                ctx.setFillColor(UIColor.gray.cgColor)
                ctx.fillPath()
            } else {
                ctx.setFillColor(_level.getColor().cgColor)
                ctx.fillPath()
            }
        }
        ctx.restoreGState()
    }
}

private enum Level: Int {
    case noSignal
    case veryLow
    case low
    case good
    case excellent

    fileprivate func getColor() -> UIColor {
        switch self {
        case .noSignal, .veryLow:
            return .red
        case .low:
            return .orange
        case .good, .excellent:
            return .green
        }
    }
}
