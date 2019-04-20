//
//  Array+Promise.swift
//  Pace
//
//  Created by Julius Sander on 20/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

/// A Queue of actions to be chained in asynchronous callbacks
struct AsyncQueue<Element> {
    /// An alias for the error handler for use in `promiseChain`.
    typealias ErrorHandler = (Error?) -> Void

    /// An alias for the callback for the elements to promise chain.
    typealias ElementCallback = (Element, @escaping ErrorHandler) -> Void

    /// The queue of elements to perform asynchronous chaining on.
    private let elements: [Element]

    init(elements: [Element]) {
        self.elements = elements
    }

    /// Chains promises on this array of elements. Breaks once a promise returns an error
    func promiseChain(callback: @escaping ElementCallback, errorHandler: ErrorHandler? = nil) {
        recursiveChaining(index: 0, asyncCall: callback, errorHandler: errorHandler)
    }

    /// Recursively adds and chains callbacks to this array of actions.
    private func recursiveChaining(index: Int,
                                   asyncCall: @escaping ElementCallback,
                                   errorHandler: ErrorHandler?) {
        guard elements.indices.contains(index) else {
            return
        }
        asyncCall(elements[index]) { error in
            guard error == nil else {
                errorHandler?(error)
                return
            }
            self.recursiveChaining(index: index + 1, asyncCall: asyncCall, errorHandler: errorHandler)
        }
    }
}
