//
//  QuerySnapshot+Extension.swift
//  Pace
//
//  Created by Tan Zheng Wei on 25/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import Firebase

extension QuerySnapshot {
    /// Pipeline requests when joining and retrieving data on foreign keys
    /// Callback is called when all requests have returned
    func join(collection: CollectionReference, on foreignKey: String, nestDataTo dataKey: String,
              callback: @escaping ([[String: Any]]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var docsData = [[String: Any]]()
        for document in documents {
            var data = document.getData()
            guard let fkValue = data[foreignKey] as? String else {
                continue
            }
            dispatchGroup.enter()
            collection.document(fkValue).getDocument { snapshot, error in
                guard
                    let snapshot = snapshot else {
                        return
                }
                data[dataKey] = snapshot.getData()
                docsData.append(data)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            callback(docsData)
        }
    }
}
