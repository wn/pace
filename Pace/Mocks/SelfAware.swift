//
//  SelfAware.swift
//  Pace
//
//  Created by Yuntong Zhang on 13/4/19.
//  Referenced from: http://jordansmith.io/handling-the-deprecation-of-initialize/
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import UIKit

protocol SelfAware: class {
    static func awake()
}

class RuntimeInjector {
    static func injectAwake() {
        let typeCount = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass?>.allocate(capacity: typeCount)
        let autoreleaseintTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        // get all types
        objc_getClassList(autoreleaseintTypes, Int32(typeCount))
        for index in 0..<typeCount {
            // invoke awake() method if the type conforms to SelfAware
            (types[index] as? SelfAware.Type)?.awake()
        }
        types.deallocate()
    }
}

extension UIApplication {
    private static let runOnce: Void = {
        RuntimeInjector.injectAwake()
    }()

    open override var next: UIResponder? {
        UIApplication.runOnce
        return super.next
    }
}
