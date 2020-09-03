//
//  UserService.swift
//  WatchRoom
//
//  Created by Bogdan on 21/8/20.
//

import Foundation
import FirebaseFirestore
import FirebaseCrashlytics

class UserService {
    static let shared = UserService()
    private init() {}
    
    //MARK: Variables
    var watchList = [Int]()
    
    func addToWatchList(userId: String, movieId: Int, completion: ((Bool?) -> Void)? = nil) {
        userWatchListDb.document().setData(["user_id": userId, "movie_id": String(movieId), "date": Date()]) { (error) in
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                completion?(true)
                return
            }
            completion?(true)
        }
    }
    
    func removeFromWatchList(userId: String, movieId: Int, completion: ((Bool?) -> Void)? = nil) {
        userWatchListDb.whereField("user_id", isEqualTo: userId).whereField("movie_id", isEqualTo: String(movieId)).getDocuments { (snapshot, error) in
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                completion?(true)
                return
            } else {
                for document in snapshot!.documents {
                    document.reference.delete { (error) in
                        if let error = error {
                            Crashlytics.crashlytics().record(error: error)
                            completion?(true)
                            return
                        }
                        completion?(true)
                    }
                }
            }
        }
    }
    
    func getWatchList(userId: String, completion: @escaping ([Int]?) -> Void) {
        watchList.removeAll()
        userWatchListDb.whereField("user_id", isEqualTo: userId).order(by: "date", descending: true).getDocuments { [weak self](snapshot, error) in
            guard let self = self else {return}
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                completion(nil)
                return
            } else {
                for document in snapshot!.documents {
                    let data = document.data()
                    let movieId = Int((data["movie_id"] as! NSString).intValue)
                    self.watchList.append(Int(movieId))
                }
                completion(self.watchList)
            }
        }
    }
}
