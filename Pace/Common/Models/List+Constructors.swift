//
//  List+Constructors.swift
//  Pace
//
//  Created by Julius Sander on 30/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import RealmSwift

extension List where Element: Object {
    /// Constructs a list with an existing array of elements.
    /// - Parameter contentsOf: the array of elements
    convenience init(contentsOf elements: [Element]) {
        self.init()
        self.append(objectsIn: elements)
    }

    /// Constructs a list with onle one existing elements.
    /// - Parameter _: The first (and only) element to initiate this List with.
    convenience init(_ firstElement: Element) {
        self.init(contentsOf: [firstElement])
    }
}
