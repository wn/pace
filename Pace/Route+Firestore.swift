//
//  Route+Firestore.swift
//  Pace
//
//  Created by Tan Zheng Wei on 19/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension Route {
    /// Retrieves all `Route`s from the Firestore database.
    static func all(firestore: Firestore, callback: @escaping ([Route]?) -> Void) {
        let routesRef = firestore.collection(FireDB.routes)
        routesRef.getDocuments { querySnapshot, err in
            guard err == nil else {
                print("Error acquiring documents")
                return
            }
            let routes = querySnapshot?.documents
                .compactMap { Route(docId: $0.documentID, document: $0.data()) }
            callback(routes)
        }
    }
}
