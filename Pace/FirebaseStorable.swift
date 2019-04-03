//
//  FirebaseStorable.swift
//  Pace
//
//  Created by Julius Sander on 4/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

/// Represents a model/object that can be stored and retrieve from Firebase.
protocol FirebaseStorable {
    /// Returns a dictionary to be used for storing into Firebase.
    var asDictionary: [String: Any ] { get }
}
