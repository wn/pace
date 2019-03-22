//
//  UserManager.swift
//  Pace
//
//  Created by Julius Sander on 22/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase

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
    static var usersCollectionReference: CollectionReference {
        return FirebaseDB.users
    }

    /// The document reference for this user.
    static var currentUserRef: DocumentReference? {
        guard let currentID = currentID else {
            return nil
        }
        return usersCollectionReference.document("\(currentID)")
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
    static func getCurrentUser(_ completion: @escaping (User?) -> Void) {
        guard let currentID = currentID else {
            print("NOT LOGGED IN")
            completion(nil)
            return
        }
        currentUserRef?.getDocument { snapshot, err in
            guard let snapshot = snapshot, let data = snapshot.data(), err == nil else {
                print(err.debugDescription)
                print("SNAPSHOT FAILED")
                completion(nil)
                return
            }
            completion(User(docId: currentID, data: data))
        }
    }

    /// Gets information about a user and performs `completion` on it.
    /// If there is some other error when accessing the document (e.g. unauthorised user),
    /// `completion` would be performed on `nil`.
    /// - Parameters:
    ///   - completion: The callback for when the user is retrieved.
    static func getUser(id: String, _ completion: @escaping (User?) -> Void) {
        userRef(forUserId: id).getDocument { snapshot, err in
            guard let snapshot = snapshot, let data = snapshot.data(), err == nil else {
                print(err.debugDescription)
                completion(nil)
                return
            }
            completion(User(docId: id, data: data))
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
    static func logIn(with credential: AuthCredential, completion: @escaping (Bool) -> Void) {
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
}
