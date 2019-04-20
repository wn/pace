//
//  SaveButton.swift
//  Pace
//
//  Created by Ang Wei Neng on 19/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class SaveButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        let image = UIImage(named: Images.saveButton)?.withRenderingMode(.alwaysOriginal)
        let widthConstraint = widthAnchor.constraint(equalToConstant: 30)
        let heightConstraint = heightAnchor.constraint(equalToConstant: 30)
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        setImage(image, for: .normal)
    }
}
