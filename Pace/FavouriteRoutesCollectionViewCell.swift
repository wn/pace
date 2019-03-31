//
//  FavouriteRoutesCollectionViewCell.swift
//  Pace
//
//  Created by Ang Wei Neng on 22/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class FavouriteRoutesCollectionViewCell: UICollectionViewCell {
    weak var route: Route? = nil {
        didSet {
            guard let route = route else {
                return
            }
            mapPreview.image = route.thumbnail
            routeLabel.text = route.name
        }
    }

    @IBOutlet private weak var mapPreview: UIImageView!
    @IBOutlet private weak var routeLabel: UILabel!
}
