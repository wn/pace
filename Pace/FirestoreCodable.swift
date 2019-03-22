//
//  FirestoreCodable.swift
//  Pace
//
//  Created by Julius Sander on 21/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import Firebase

protocol FirestoreCodable {
    /// The "decoding" function used to build an object from Firestore data.
    init?(docId: String, data: [String: Any])

    /// The "encoding" function used to encode the object into a Firestore-able object.
    func toFirestoreDoc() -> [String: Any]
}

/// Temporarily commented out.
extension FirestoreCodable {
    /// To get a reference for custom filtered queries, for example
//    static func collectionReference(from firestore: Firestore) -> CollectionReference {
//        return firestore.collection(Self.collectionID)
//    }

    // MARK: - Default methods for a model that is stored on firebase.
    /// Adds this object to Firestore.
//    func add(callback: @escaping (Error?) -> Void) {
//        let collectionReference = Self.collectionReference(from: firestore)
//        collectionReference.addDocument(data: toFirestoreDoc()) { callback($0) }
//    }

    /// Returns all the models in this Firestore for this object
//    static func all(from firestore: Firestore, start: Int? = 0, limit: Int? = 50,
//                    callback: @escaping ([Self]?) -> Void) {
//        let collectionReference = Self.collectionReference(from: firestore)
//        collectionReference.addSnapshotListener { querySnapshot, err in
//            guard err == nil else {
//                print("Error acquiring documents")
//                return
//            }
//            let models = querySnapshot?.documents.compactMap { Self(docId: $0.documentID, dictionary: $0.data()) }
//            callback(models)
//        }
//    }
}
