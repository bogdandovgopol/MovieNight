//
//  TMDBAuthService.swift
//  WatchRoom
//
//  Created by Bogdan on 17/9/20.
//

import Foundation
import FirebaseCrashlytics

struct TMDBAuthService {
    static let shared = TMDBAuthService()
    private init() {}
    
    
    func createRequestToken(completion: @escaping (String?) -> Void) {
        let parameters = ["redirect_to": URLSchemes.TMDBApprovedLogin]
        let headers = [
            "content-type": "application/json;charset=utf-8",
            "authorization": "Bearer \(Secrets.MOVIEDB_ACCESS_TOKEN)"
        ]
        
        RESTful.request(path: TMDB_API.v4.Auth.CreateRequestTokenURL, method: .post, parameters: parameters, headers: headers) { (result) in
            switch result {
            case .success(let data):
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let auth = try jsonDecoder.decode(TMDBAuth.self, from: data)
                    guard let requestToken = auth.requestToken else {
                        completion(nil)
                        return
                    }
                    
                    completion(requestToken)
                } catch {
                    Crashlytics.crashlytics().record(error: error)
                    completion(nil)
                }
            case .failure(let error):
                Crashlytics.crashlytics().record(error: error)
                completion(nil)
            }
        }
    }
    
    private func createSessionId(fromAccessToken accessToken: String, completion: @escaping (String?) -> Void) {
        let parameters = ["access_token": accessToken]
        let headers = [
            "content-type": "application/json;charset=utf-8"
        ]
        RESTful.request(path: TMDB_API.v3.Auth.CreateSessionIdURL + "?api_key=\(Secrets.MOVIEDB_API_KEY)", method: .post, parameters: parameters, headers: headers) { (result) in
            switch result {
            case .success(let data):
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let auth = try jsonDecoder.decode(TMDBAuth.self, from: data)
                    guard let sessionId = auth.sessionId, auth.success == true else {
                        completion(nil)
                        return
                    }
                    
                    completion(sessionId)
                } catch {
                    Crashlytics.crashlytics().record(error: error)
                    completion(nil)
                }
            case .failure(let error):
                Crashlytics.crashlytics().record(error: error)
                completion(nil)
            }
        }
    }
    
    private func getAccountId(withSessionId sessionId: String, completion: @escaping(Int?) -> Void) {
        let parameters = ["api_key": Secrets.MOVIEDB_API_KEY, "session_id": sessionId]
        RESTful.request(path: TMDB_API.v3.Account.AccountDetailsURL, method: .get, parameters: parameters, headers: nil) { (result) in
            switch result {
            case .success(let data):
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let auth = try jsonDecoder.decode(TMDBAuth.self, from: data)
                    guard let accountId = auth.id else {
                        completion(nil)
                        return
                    }
                    
                    completion(accountId)
                } catch {
                    Crashlytics.crashlytics().record(error: error)
                    completion(nil)
                }
            case .failure(let error):
                Crashlytics.crashlytics().record(error: error)
                completion(nil)
            }
        }
    }
    
    func getCredentials(withRequestToken requestToken: String, completion: @escaping (TMDBCredentials?) -> Void) {
        let parameters = ["request_token": requestToken]
        
        let headers = [
            "content-type": "application/json;charset=utf-8",
            "authorization": "Bearer \(Secrets.MOVIEDB_ACCESS_TOKEN)"
        ]
        
        RESTful.request(path: TMDB_API.v4.Auth.AccessTokenURL, method: .post, parameters: parameters, headers: headers) { (result) in
            switch result {
            case .success(let data):
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let auth = try jsonDecoder.decode(TMDBAuth.self, from: data)
                    guard auth.success == true, let accessToken = auth.accessToken, let accountIdV4 = auth.accountId else {
                        completion(nil)
                        return
                    }
                    
                    createSessionId(fromAccessToken: accessToken) { (sessionId) in
                        guard let sessionId = sessionId else {
                            completion(nil)
                            return
                        }
                        
                        getAccountId(withSessionId: sessionId) { (accountIdV3) in
                            guard let accountIdV3 = accountIdV3 else {
                                completion(nil)
                                return
                            }
                            
                            let credentials = TMDBCredentials(accessToken: accessToken, sessionId: sessionId, accountIdV3: accountIdV3, accountIdV4: accountIdV4)
                            completion(credentials)
                        }
                    }
                } catch {
                    Crashlytics.crashlytics().record(error: error)
                    completion(nil)
                }
            case .failure(let error):
                Crashlytics.crashlytics().record(error: error)
                completion(nil)
            }
        }
    }
    
    func deleteSession(session: String, completion: @escaping (WRError?) -> Void) {
        let parameters = ["session_id": session]
        
        let headers = [
            "content-type": "application/json;charset=utf-8"
        ]
        
        RESTful.request(path: TMDB_API.v3.Auth.DeleteSessionURL, method: .delete, parameters: parameters, headers: headers) { (result) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let response = try decoder.decode(TMDBActionResponse.self, from: data)
                    print(response)
                    if response.success == false {
                        completion(.tmdbFailedToSignOut)
                        return
                    }
                    completion(nil)
                } catch {
                    completion(.tmdbFailedToSignOut)
                }
            case .failure(_):
                completion(.tmdbFailedToSignOut)
            }
        }
    }
    
}
