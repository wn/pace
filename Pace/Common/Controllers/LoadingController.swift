//
//  LoadingController.swift
//  Pace
//
//  Created by Tan Zheng Wei on 15/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

class LoadingController: UIViewController {
    var isLoading: Bool = false {
        didSet {
            if !isLoading && oldValue {
                didCompleteLoading()
            } else if isLoading && !oldValue {
                didStartLoading()
            }
        }
    }

    func didStartLoading() {
        
    }

    func didCompleteLoading() {

    }
}
