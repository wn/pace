//
//  NSLayoutConstraint+Extension.swift
//  Pace
//
//  Created by Tan Zheng Wei on 9/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    /// Generates a duplicate of the constraint with a new constant
    func replace(newMultiplier: CGFloat? = nil,
                 newConstant: CGFloat? = nil) -> NSLayoutConstraint {
        let newMul: CGFloat = newMultiplier ?? multiplier
        let newConst: CGFloat = newConstant ?? constant
        return NSLayoutConstraint(item: firstItem as Any,
                                  attribute: firstAttribute,
                                  relatedBy: relation,
                                  toItem: secondItem,
                                  attribute: secondAttribute,
                                  multiplier: newMul,
                                  constant: newConst)
    }
}
