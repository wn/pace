//
//  FriendsFeedCollectionViewCell.swift
//  Pace
//
//  Created by Ang Wei Neng on 21/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class FriendsFeedCollectionViewCell: UICollectionViewCell {
    let distance = 100
    private var _friend = "WEINENG"
    private var _id: String?
    var friend: String {
        get {
            return _friend
        }
        set(name) {
            nameLabel.text = name
            _friend = name
        }
    }

    @IBOutlet private weak var nameLabel: UILabel!

    let numOfRunners = 100
}
