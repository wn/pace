//
//  UserManager.swift
//  Pace
//
//  Created by Julius Sander on 22/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import FirebaseAuth
import FacebookCore
import Firebase

/// This class is a singleton manager for all user & friend related methods.
class UserManager {

    /// The current id of the user.
    static var currentID: String? {
        return Auth.auth().currentUser?.uid
    }

    /// Returns if a user is logged in
    static var isLoggedIn: Bool {
        return currentID != nil
    }

    /// The collection reference for all the users.
    private static var usersCollectionReference: CollectionReference {
        return FirebaseDB.users
    }

    /// The collection reference for all the friend requests.
    private static var friendRequestsCollectionReference: CollectionReference {
        return FirebaseDB.friend_requests
    }

    /// The document reference for this user.
    static var currentUserRef: DocumentReference? {
        guard let currentID = currentID else {
            return nil
        }
        return usersCollectionReference.document("\(currentID)")
    }

    /// The document reference for this user's friend requests
    static var currentUserRequestsRef: DocumentReference? {
        guard let currentID = currentID else {
            return nil
        }
        return friendRequestsCollectionReference.document("\(currentID)")
    }

    /// The document reference for a user.
    /// - Parameters:
    ///   - docId: The ID of the document to retrieve.
    static func userRef(forUserId docId: String) -> DocumentReference {
        return usersCollectionReference.document("\(docId)")
    }

    /// Gets information about the current user and performs `completion` on it.
    /// If the user is not signed in or there is some other error when accessing
    /// the document, `completion` would be performed on `nil`.
    /// - Parameters:
    ///   - completion: The callback for when the user is retrieved.
    static func currentUser(_ completion: @escaping (User?) -> Void) {
        guard let currentID = currentID, let currentUserRef = currentUserRef else {
            print("NOT LOGGED IN")
            completion(nil)
            return
        }
        currentUserRef.getDocument { snapshot, err in
            guard let snapshot = snapshot, err == nil else {
                print(err.debugDescription)
                print("SNAPSHOT FAILED")
                completion(nil)
                return
            }
            completion(User(data: snapshot.getData()))
        }
    }

    /// Gets information about a user and performs `completion` on it.
    /// If there is some other error when accessing the document (e.g. unauthorised user),
    /// `completion` would be performed on `nil`.
    /// - Parameters:
    ///   - completion: The callback for when the user is retrieved.
    static func getUser(userId: String, _ completion: @escaping (User?) -> Void) {
        userRef(forUserId: userId).getDocument { snapshot, err in
            guard let snapshot = snapshot, err == nil else {
                print(err.debugDescription)
                completion(nil)
                return
            }
            completion(User(data: snapshot.getData()))
        }
    }

    // MARK: - Account methods
    static func createAccount(authUid: String, displayName: String, completion: @escaping (Bool) -> Void) {
        usersCollectionReference.document(authUid).setData(["name": displayName]) { err in
            if let err = err {
                print(err.localizedDescription)
                completion(false)
                return
            }
            completion(true)
        }
    }

    /// Logs the user into the app.
    /// - Parameters:
    ///   - credential: The credential to log in with.
    ///   - completion: The callback for completion. Would perform differently based on the authentication result.
    private static func logIn(with credential: AuthCredential, completion: @escaping (Bool) -> Void) {
        if isLoggedIn {
            return
        }
        Auth.auth().signInAndRetrieveData(with: credential) { authResult, err in
            // If we cannot sign this guy in, we run completion for an unauthenticated result.
            guard let authResult = authResult, err == nil else {
                completion(false)
                return
            }
            let uid = authResult.user.uid
            usersCollectionReference.document(uid).getDocument { snapshot, err in
                guard let snapshot = snapshot, err == nil else {
                    completion(false)
                    return
                }
                // if account does not exist, try to create an account
                guard snapshot.exists else {
                    createAccount(authUid: uid, displayName: authResult.user.displayName!, completion: completion)
                    return
                }
                // otherwise just run completion
                completion(true)
            }
        }
    }

    /// Logs the user into the app using a facebook token.
    /// - Parameters:
    ///   - credential: The Facebook token to log in with.
    ///   - completion: The callback for completion. Would perform differently based on the authentication result.
    static func logIn(withFacebookToken accessToken: AccessToken, completion: @escaping (Bool) -> Void) {
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
        logIn(with: credential, completion: completion)
    }

    /// Logs the current user out
    static func logOut(_ completion: @escaping () -> Void) throws {
        try Auth.auth().signOut()
        completion()
    }

    // MARK: - Social network methods
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
        guard isLoggedIn, let currentID = currentID else {
            completion(NSError())
            return
        }
        friendRequestsCollectionReference.document(userId)
            .updateData(["incoming": FieldValue.arrayUnion([currentID])],
                        completion: completion)
    }

    /// Gets requests for this user.
    static func getRequests(completion: @escaping ([String]?, Error?) -> Void) {
        guard isLoggedIn, let currentUserRequestsRef = currentUserRequestsRef else {
            completion(nil, NSError())
            return
        }
        currentUserRequestsRef.getDocument { snapshot, err in
            guard
                err == nil,
                let data = snapshot?.data(),
                let incoming = data["incoming"] as? [String]
                else {
                    completion(nil, err)
                    return
            }
            completion(incoming, nil)
        }
    }
}
