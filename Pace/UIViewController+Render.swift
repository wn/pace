//
//  UIViewController+Render.swift
//  Pace
//
//  Created by Ang Wei Neng on 25/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

extension UIViewController: UIViewControllerTransitioningDelegate {
    func renderChildController(_ child: UIViewController) {
        self.addChild(child)
        view.addSubview(child.view)
        didMove(toParent: self)
        child.viewWillAppear(true)
    }

    func derenderChildController(_ moveToParent: Bool = true) {
        guard let parent = self.parent else {
            return
        }
        view.removeFromSuperview()
        removeFromParent()
        guard moveToParent else {
            return
        }
        willMove(toParent: nil)
        parent.viewWillAppear(true)
    }
}
