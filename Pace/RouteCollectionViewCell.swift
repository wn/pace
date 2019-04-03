//
//  RouteCollectionViewCell.swift
//  Pace
//
//  Created by Tan Zheng Wei on 3/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class RouteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private var content: UIView!
    @IBOutlet private var thumbnail: UIImageView!
    @IBOutlet private var startLocation: UILabel!
    @IBOutlet private var endLocation: UILabel!
    @IBOutlet private var distance: UILabel!
    @IBOutlet private var pacesAvailable: UILabel!
    @IBOutlet private var numRunners: UILabel!
    private var currentRoute: Route?
    private var routeStats: RouteStats?

    var route: Route? {
        get {
            return currentRoute
        }
        set(route) {
            currentRoute = route
            routeStats = currentRoute?.generateStats()
            guard let currentRoute = currentRoute,
                let routeStats = routeStats else {
                return
            }
            thumbnail.image = currentRoute.thumbnail
            routeStats.startingLocation.address { address in
                self.startLocation.text = address
            }
            routeStats.endingLocation.address { address in
                self.endLocation.text = address
            }
            distance.text = String(routeStats.totalDistance) + "km"
            pacesAvailable.text = "Paces: " + String(currentRoute.paces.count)
            numRunners.text = "Runners: " + String(routeStats.numOfRunners)
        }
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

    private func loadXib() {
        Bundle.main.loadNibNamed(Xibs.routeCollectionViewCell, owner: self, options: nil)
        addSubview(content)
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
