//
//  Constants.swift
//  WatchRoom
//
//  Created by Bogdan on 20/8/20.
//

import Foundation
import Firebase
import FirebaseFirestore

//MARK: Variables
let db = Firestore.firestore()
let usersDb = db.collection("users")

//MARK: Constants
enum StoryboardIDs {
    static let MainStoryboard = "Main"
    static let AlertStoryboard = "Alert"
}

enum VCIDs {
    static let AlertVC = "AlertVC"
    static let SignInVC = "SignInVC"
}

enum CellIDs {

}

enum SegueIDs {

}
