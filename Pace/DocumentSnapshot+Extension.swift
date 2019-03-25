//
//  QueryDocumentSnapshot+Extension.swift
//  Pace
//
//  Created by Tan Zheng Wei on 25/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import Firebase

extension DocumentSnapshot {
    // To replace use of data()
    // Includes the documentID as a key in the dictionary as well
    public func getData() -> [String: Any] {
        guard var data = self.data() else {
            return [String: Any]()
        }
        data[FireDB.primaryKey] = self.documentID
        return data
    }
}
