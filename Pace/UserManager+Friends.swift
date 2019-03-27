//
//  UserManager+Friends.swift
//  Pace
//
//  Created by Julius Sander on 26/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import Firebase

extension UserManager {
    /// The collection reference for all the friend requests.
    private static var friendRequestsCollectionReference: CollectionReference {
        return FirebaseDB.friendRequests
    }

    /// The document reference for this user's friend requests
    static var currentUserRequestsRef: DocumentReference? {
        guard let currentID = currentId else {
            return nil
        }
        return friendRequestsCollectionReference.document("\(currentID)")
    }

    /// Gets the friends' names of a person and performs callback with it.
    static func getFriends(_ completion: @escaping ([String]?, Error?) -> Void) {
        guard isLoggedIn, let userRef = currentUserRef else {
            completion(nil, NSError())
            return
        }
        userRef.getDocument { snapshot, err in
            guard let snapshot = snapshot, err == nil else {
                completion(nil, err)
                return
            }
            let dispatchGroup = DispatchGroup()
            var friendNames: [String] = []
            guard let friends = snapshot.data()?["friends"] as? [String: Any] else {
                completion(nil, NSError())
                return
            }
            friends.keys.forEach { userId in
                dispatchGroup.enter()
                FirebaseDB.users.document(userId).getDocument { friendSnap, err in
                    guard
                        err == nil,
                        let friend = friendSnap,
                        let name = friend.data()?["name"] as? String
                        else {
                            dispatchGroup.leave()
                            return
                    }
                    friendNames.append(name)
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: DispatchQueue.main) {
                completion(friendNames, nil)
            }
        }
    }

    /// Sends a request to this user.
    static func sendRequestTo(userId: String, completion: @escaping (Error?) -> Void) {
        guard isLoggedIn, let currentId = currentId else {
            completion(NSError())
            return
        }
        // We want to write both an incoming and an outgoing invite.
        let writeBatch = FirebaseDB.firestore.batch()
        let receiverDoc = friendRequestsCollectionReference.document(userId)
        writeBatch.updateData(["incoming": FieldValue.arrayUnion([currentId])], forDocument: receiverDoc)
        
        let senderDoc = friendRequestsCollectionReference.document(currentId)
        writeBatch.updateData(["outgoing": FieldValue.arrayUnion([userId])], forDocument: senderDoc)
        
        writeBatch.commit(completion: completion)
    }

    /// Gets requests for this user.
    // We are adding a listener to this as we would potentially need to observe and update this value.
    static func observeRequests(_ listener: @escaping ([FriendRequest]?, Error?) -> Void) -> ListenerRegistration? {
        guard isLoggedIn, let currentUserRequestsRef = currentUserRequestsRef else {
            listener(nil, NSError())
            return nil
        }
        return currentUserRequestsRef.addSnapshotListener { snapshot, err in
            guard
                err == nil,
                let data = snapshot?.data(),
                let incoming = data["incoming"] as? [String]
                else {
                    listener(nil, err)
                    return
            }
            listener(incoming.map { FriendRequest($0) }, nil)
        }
    }

    static func acceptRequest(completion: @escaping (Error?) -> Void) {
        guard isLoggedIn, let _ = currentUserRequestsRef else {
            completion(NSError())
            return
        }
        completion(nil)
    }
}
