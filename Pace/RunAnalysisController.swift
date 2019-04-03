//
//  RunAnalysisController.swift
//  Pace
//
//  Created by Tan Zheng Wei on 30/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class RunAnalysisController: UIViewController {
    weak var run: Run?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = Titles.run
    }
}
