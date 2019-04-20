//
//  ActivityViewController+Drawer.swift
//  Pace
//
//  Created by Ang Wei Neng on 3/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import GoogleMaps

// MARK: - Extension for drawer
extension ActivityViewController {

    var currentDrawer: RouteDrawerViewController? {
        return children.first { $0 is RouteDrawerViewController } as? RouteDrawerViewController
    }

    var pullUpDrawer: RouteDrawerViewController {
        let currentPullUpController = children.first { $0 is RouteDrawerViewController } as? RouteDrawerViewController
        let pullUpController = currentPullUpController ??
            UIStoryboard(name: Identifiers.storyboard, bundle: nil)
            .instantiateViewController(withIdentifier: Identifiers.searchViewController)
            as! RouteDrawerViewController
        if originalPullUpControllerViewSize == .zero {
            originalPullUpControllerViewSize = pullUpController.view.bounds.size
        }
        return pullUpController
    }

    func showPullUpController() {
        guard children.filter({ $0 is RouteDrawerViewController }).isEmpty else {
            return
        }
        let pullUpController = pullUpDrawer
        _ = pullUpController.view // call pullUpController.viewDidLoad()
        addPullUpController(pullUpController,
                            initialStickyPointOffset: pullUpController.initialPointOffset,
                            animated: true)
    }
}
