//
//  WifiIcon.swift
//  Pace
//
//  Created by Ang Wei Neng on 18/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class WifiIcon: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        //custom logic goes here
        let origImage = UIImage(named: Images.wifiIcon)
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        image = tintedImage
        connected()
        superview?.bringSubviewToFront(self)
    }

    func connected() {
        tintColor = .green
    }

    func disconnected() {
        tintColor = .red
    }
}


