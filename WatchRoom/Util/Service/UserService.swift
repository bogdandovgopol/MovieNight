//
//  UserService.swift
//  WatchRoom
//
//  Created by Bogdan on 23/9/20.
//

import Foundation
import KeychainAccess
import FirebaseAuth

struct UserService {
    static let shared = UserService()
    private init() {}
    
    private func signOutFromTMDB(completion: @escaping (WRError?) -> Void) {
        PersistanceService.retrieveTMDBCredentials { (result) in
            switch result {
            case .success(let credentials):
                guard let credentials = credentials else {
                    completion(nil)
                    return
                }
                TMDBAuthService.shared.deleteSession(session: credentials.sessionId) { (error) in
                    PersistanceService.removeCredentials()
                    if let _ = error { return }
                    completion(nil)
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func signOut(completion: @escaping (WRError?) -> Void) {
        do {
            try Auth.auth().signOut()
            signOutFromTMDB(completion: completion)
        } catch {
            signOutFromTMDB(completion: completion)
            completion(.unableToSignOut)
        }
    }
    
}
