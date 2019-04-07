//
//  GMSMapView+Extensions.swift
//  Pace
//
//  Created by Tan Zheng Wei on 6/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import GoogleMaps

extension GMSMapView {
    func draw(run: Run) {
        let path = GMSMutablePath()
        for checkpoint in run.checkpoints {
            guard let coordinate = checkpoint.location?.coordinate else {
                continue
            }
            path.add(coordinate)
        }
        let line = GMSPolyline(path: path)
        line.strokeColor = .blue
        line.strokeWidth = 5
        line.map = self
    }
}
