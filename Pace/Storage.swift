//
//  Storage.swift
//  Pace
//
//  Created by Julius Sander on 26/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import FirebaseStorage

/// Manager for retrieving stored files, mostly images
class StorageManager {
    /// A type for image callbacks.
    typealias UIImageCallback = (UIImage?, Error?) -> Void

    /// Root folder for all storage files.
    static private let storage = Storage.storage()

    /// Reference for the root storage folder.
    static private let storageRef = storage.reference()

    /// User profile pictures folder reference.
    static let userPicturesStorage = storageRef.child("profile_pictures")

    /// Route preview pictures folder reference.
    static let previewPicturesStorage = storageRef.child("route_previews")

    /// Default limit (1 MB)
    static let defaultLimit: Int64 = 1_024 * 1_024

    /// Gets an image
    static private func getPictureFrom(imageRef: StorageReference, limit: Int64,
                                       completion: @escaping UIImageCallback) {
        imageRef.getData(maxSize: limit) { imageData, error in
            guard error == nil, let imageData = imageData else {
                completion(nil, error)
                return
            }
            completion(UIImage(data: imageData), nil)
        }
    }

    /// Gets an image with the default size limit
    static private func getPictureFrom(imageRef: StorageReference, completion: @escaping UIImageCallback) {
        getPictureFrom(imageRef: imageRef, limit: defaultLimit, completion: completion)
    }

    /// Gets a user's image
    static func getUserPicture(for userId: String, completion: @escaping UIImageCallback) {
        getPictureFrom(imageRef: userPicturesStorage.child("\(userId).jpeg"), completion: completion)
    }

    /// Gets the route preview
    static func getRoutePreview(for routeId: String, completion: @escaping UIImageCallback) {
        getPictureFrom(imageRef: previewPicturesStorage.child("\(routeId).jpeg"), completion: completion)
    }
}
