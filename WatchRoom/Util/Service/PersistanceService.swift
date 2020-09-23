//
//  PersistanceService.swift
//  WatchRoom
//
//  Created by Bogdan on 19/9/20.
//

import Foundation
import KeychainAccess
import FirebaseCrashlytics

enum PersistanceActionType {
    case add, remove
}

enum PersistanceService {
    static private let keychain = Keychain()
    static private let defaults = UserDefaults()
    
    enum Keys {
        static let tmdbCredentials = "dev.dovgopol.MovieNight.tmdb.credentials"
        static let isTMDBLoggedIn = "isTMDBLoggedIn"
    }
    
    static func removeCredentials() -> WRError? {
        do {
            try keychain.remove(Keys.tmdbCredentials)
            return nil
        } catch {
            Crashlytics.crashlytics().record(error: error)
            return .keychainUnableToRemoveTMDBCredentials
        }
    }
    
    static func updateCredentials(with credentials: TMDBCredentials, actionType: PersistanceActionType, completion: @escaping (WRError?) -> Void) {
        retrieveTMDBCredentials { (result) in
            switch result {
            case .success(_):
                switch actionType {
                case .add:
                    completion(save(credentials: credentials))

                case .remove:
                    completion(removeCredentials())
                    break
                }
            case .failure(let error):
                Crashlytics.crashlytics().record(error: error)
                completion(.keychainUnableToSaveTMDBCredentials)
            }
        }
    }
    
    static func retrieveTMDBCredentials(completion: @escaping (Result<TMDBCredentials?, WRError>) -> Void) {
        do {
            guard let credentialsData = try keychain.getData(Keys.tmdbCredentials) else {
                completion(.success(nil))
                return
            }
            
            let decoder = JSONDecoder()
            let credentials = try decoder.decode(TMDBCredentials.self, from: credentialsData)
            completion(.success(credentials))
        } catch {
            Crashlytics.crashlytics().record(error: error)
            completion(.failure(.keychainUnableToRetrieveTMDBCredentials))
        }
    }
    
    static func save(credentials: TMDBCredentials) -> WRError? {
        do {
            let encoder = JSONEncoder()
            let encodedCredentials = try encoder.encode(credentials)
            try keychain.set(encodedCredentials, key: Keys.tmdbCredentials)
            return nil
        } catch {
            Crashlytics.crashlytics().record(error: error)
            return .keychainUnableToSaveTMDBCredentials
        }
    }
    
    
}
