//
//  NavigableController .swift
//  Pace
//
//  Created by Tan Zheng Wei on 30/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class NavigableController: UINavigationController {
    var navigationDelegate: UINavigationBarDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadNavigationBar()
    }
    
    func loadNavigationBar() {
    }
}
