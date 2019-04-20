//
//  Array+Promise.swift
//  Pace
//
//  Created by Julius Sander on 20/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

extension Array {
    /// An alias for the error handler for use in `promiseChain`.
    typealias ErrorHandler = (Error?) -> Void

    /// An alias for the callback for the elements to promise chain.
    typealias ElementCallback = (Element, @escaping ErrorHandler) -> Void

    /// Chains promises on this array of elements. Breaks once a promise returns an error
    func promiseChain(callback: ElementCallback, errorHandler: ErrorHandler? = nil) {
        for element in self {
            let dispatchGroup = DispatchGroup()
            var error: Error?
            dispatchGroup.enter()
            callback(element, {
                error = $0
                dispatchGroup.leave()
            })
            dispatchGroup.wait()
            if let error = error {
                errorHandler?(error)
                break
            }
        }
    }
}
