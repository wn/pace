//
//  UIAlertController+Extensions.swift
//  Pace
//
//  Created by Ang Wei Neng on 17/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func showMessage(_ controller: UIViewController, msg message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        controller.present(alert, animated: true)
    }
}
