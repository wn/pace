//
//  ActivityViewController+Drawer.swift
//  Pace
//
//  Created by Ang Wei Neng on 3/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

// MARK: - Extension for drawer
extension ActivityViewController {
    private var pullUpDrawer: DrawerViewController {
        let currentPullUpController = children.first { $0 is DrawerViewController } as? DrawerViewController
        let pullUpController = currentPullUpController ??
            UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SearchViewController")
            as! DrawerViewController
        if originalPullUpControllerViewSize == .zero {
            originalPullUpControllerViewSize = pullUpController.view.bounds.size
        }
        return pullUpController
    }

    private func showPullUpController() {
        guard children.filter({ $0 is DrawerViewController }).isEmpty else {
            return
        }
        let pullUpController = pullUpDrawer
        _ = pullUpController.view // call pullUpController.viewDidLoad()
        addPullUpController(pullUpController,
                            initialStickyPointOffset: pullUpController.initialPointOffset,
                            animated: true)
    }

    func renderDrawer(/*route: Route*/) {
        showPullUpController()
        pullUpDrawer.routeStats(/*route: route*/)
    }
}
