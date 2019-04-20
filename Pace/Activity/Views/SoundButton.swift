//
//  SoundButton.swift
//  Pace
//
//  Created by Ang Wei Neng on 19/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class SoundButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        let widthConstraint = widthAnchor.constraint(equalToConstant: 30)
        let heightConstraint = heightAnchor.constraint(equalToConstant: 30)
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        VoiceAssistant.muted ? mute() : unmute()
    }

    func mute() {
        let origImage = UIImage(named: Images.muteIcon)
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        let image = tintedImage
        tintColor = UIColor.red
        setImage(image, for: .normal)
    }

    func unmute() {
        let origImage = UIImage(named: Images.soundIcon)
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        let image = tintedImage
        tintColor = UIColor.green
        setImage(image, for: .normal)
    }
}
