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
    private var profileImage: UIImage? {
        didSet {
            profileImageView.image = profileImage
        }
    }
    var friend: String {
        get {
            return _friend
        }
        set(name) {
            nameLabel.text = name
            _friend = name
        }
    }

    var id: String? {
        get {
            return _id
        }
        set(newId) {
            _id = newId
            guard let id = _id else {
                return
            }
            StorageManager.getUserPicture(for: id) { image, _ in
                self.profileImage = image
            }
        }
    }
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var profileImageView: UIImageView!

    let numOfRunners = 100
}
