//
//  RunnerMarker.swift
//  Pace
//
//  Created by Tan Zheng Wei on 6/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class RunnerMarker: UIView {
    convenience init(_ color: UIColor) {
        let radius = 16
        let frame = CGRect(x: 0, y: 0, width: radius, height: radius)
        self.init(frame: frame)
        layer.cornerRadius = CGFloat(radius / 4)
        clipsToBounds = true
    }
}
