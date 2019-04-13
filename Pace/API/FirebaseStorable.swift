//
//  FirebaseStorable.swift
//  Pace
//
//  Created by Julius Sander on 4/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

/// Represents a model/object that can be stored and retrieve from Firebase.
protocol FirebaseStorable {
    associatedtype OwnType = Self
    /// Returns a dictionary to be used for storing into Firebase.
    var asDictionary: [String: Any ] { get }
    /// Returns an instance of itself from a Firestore dictionary.
    static func fromDictionary(objectId: String?, value: [String: Any]) -> OwnType?
}
