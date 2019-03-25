//
//  ProfileViewController.swift
//  Pace
//
//  Created by Ang Wei Neng on 21/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class ProfileViewController: RequireLoginController {
    let route = Dummy.route
    var paces = [Pace]()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let user = user else {
            return
        }
        FirebaseDB.retrievePaces(of: user) { cbPaces in
            self.paces.append(contentsOf: cbPaces)
            print("paces: \(self.paces)")
        }
    }

    /// Information about routes (show how the api is working)
    private var routeInfo: UILabel = {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 300, height: 50))
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.font = UIFont(name: "System", size: 10.0)
        return label
    }()
}

