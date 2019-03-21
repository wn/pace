//
//  FriendsFeedViewController.swift
//  Pace
//
//  Created by Ang Wei Neng on 21/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class FriendsFeedViewController: UIViewController {
    // MARK: - Properties
    private let feedIdentifier = "friendsFeedCell"
    let friendsRoutes = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]
    let itemsPerRow = 1
    private let sectionInsets = UIEdgeInsets(top: 0,
                                             left: 20.0,
                                             bottom: 100.0,
                                             right: 20.0)
}

// MARK: - UICollectionViewDataSource
extension FriendsFeedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // Tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendsRoutes.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: feedIdentifier, for: indexPath) as! FriendsFeedCollectionViewCell
        cell.backgroundColor = .blue
        // Configure the cell
        return cell
    }
}

// MARK: - Collection View Flow Layout Delegate
extension FriendsFeedViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)

        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
