//
//  WatchlistService.swift
//  WatchRoom
//
//  Created by Bogdan on 20/9/20.
//

import Foundation
import FirebaseCrashlytics
import FirebaseAuth

enum TMDBSortBy: String {
    case createdAtASC = "created_at.asc"
    case createdAtDESC = "created_at.desc"
}

enum MediaType: String {
    case movie = "movie"
}

enum ActionType {
    case add
    case remove
}

final class WatchlistService {
    private var page = 1
    static let shared = WatchlistService()
    private init() {}
    
    func isMediaInWatchlist(mediaId: Int, signInType type: SignInType, completion: @escaping (Bool?) -> Void) {
        switch type {
        case .firebase:
            userWatchListDb.whereField("user_id", isEqualTo: Auth.auth().currentUser?.uid ?? "").whereField("movie_id", isEqualTo: String(mediaId)).getDocuments { (snapshot, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    Crashlytics.crashlytics().record(error: error)
                    return
                }
                
                guard let snapshot = snapshot, snapshot.documents.count > 0 else { return }
                completion(true)
            }
        case .tmdb:
            loadTMDBWatchlistWithCredentials(page) { [weak self](watchlist) in
                guard let self = self else { return }
                
                let found = watchlist.contains(where: { $0.id == mediaId })
                if found == true {
                    self.page = 1
                    completion(true)
                    return
                } else if found == false && watchlist.count > 0 {
                    self.page += 1
                    self.isMediaInWatchlist(mediaId: mediaId, signInType: type, completion: completion)
                } else {
                    self.page = 1
                    return
                }
            }
        }
    }
    
    //MARK: TMDB
    private func loadTMDBWatchlist(with credentials: TMDBCredentials, sortBy sort: TMDBSortBy, page: Int, completion: @escaping (Result<MovieFeed, WRError>) -> Void) {
        let path = TMDB_API.v4.Account.AccountDetailsURL + "/\(credentials.accountIdV4)/movie/watchlist?page=\(page)&sort_by=\(sort.rawValue)"
        let headers = ["authorization": "Bearer \(credentials.accessToken)"]
        
        RESTful.request(path: path, method: .get, parameters: nil, headers: headers) { (result) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let feed = try decoder.decode(MovieFeed.self, from: data)
                    completion(.success(feed))
                } catch {
                    Crashlytics.crashlytics().record(error: error)
                    completion(.failure(.invalidJson))
                }
            case .failure(let error):
                Crashlytics.crashlytics().record(error: error)
                completion(.failure(.unableToLoadWatchlist))
            }
        }
    }
    
    private func loadWRWatchList(completion: @escaping ([MovieDetail]) -> Void) {
        loadFirebaseWatchlist(userId: Auth.auth().currentUser?.uid ?? "") { [weak self](watchList) in
            guard let self = self else { return }
            
            let dispatchGroup = DispatchGroup()
            var movieDetails = [MovieDetail]()
            
            guard let watchList = watchList else {
                completion([])
                return
            }
            
            for item in watchList {
                guard let item = item.id else { return }
                dispatchGroup.enter()
                
                self.loadMovieDetails(id: item) { (movieDetail) in
                    guard let movieDetail = movieDetail else {
                        //dispatchGroup.leave()
                        return
                    }
                    movieDetails.append(movieDetail)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: DispatchQueue.main) {
                completion(movieDetails)
            }
        }
    }
    
    private func loadMovieDetails(id: Int, completion: @escaping (MovieDetail?) -> Void) {
        let path = "\(TMDB_API.v3.Movie.Details)/\(id)"
        let parameters = [
            "api_key": Secrets.MOVIEDB_API_KEY,
            "language": UserLocale.language
        ]
        MovieService.shared.getMovie(path: path, parameters: parameters) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let movie):
                    completion(movie)
                    break
                    
                case .failure(let error):
                    Crashlytics.crashlytics().record(error: error)
                    completion(nil)
                }
            }
        }
    }
    
    func loadWatchlist(with type: SignInType, page: Int = 1, completion: @escaping ([MovieDetail]) -> Void) {
        switch type {
        case .firebase:
            loadWRWatchList { (movies) in
                completion(movies)
            }
        case .tmdb:
            loadTMDBWatchlistWithCredentials(page) { (movies) in
                completion(movies)
            }
        }
    }
    
    private func loadTMDBWatchlistWithCredentials(_ page: Int, _ completion: @escaping ([MovieDetail]) -> Void) {
        PersistanceService.retrieveTMDBCredentials { [weak self](result) in
            guard let self = self else { return }
            
            switch(result){
            case .success(let credentials):
                guard let credentials = credentials else {
                    completion([])
                    return
                }
                self.loadTMDBWatchlist(with: credentials, sortBy: .createdAtDESC, page: page) { (result) in
                    switch result {
                    case .success(let feed):
                        guard let movies = feed.movies else {
                            completion([])
                            return
                        }
                        completion(movies)
                        
                    case .failure(let error):
                        Crashlytics.crashlytics().record(error: error)
                        completion([])
                    }
                }
            case .failure(let error):
                Crashlytics.crashlytics().record(error: error)
                completion([])
            }
        }
    }
    
    func updateTMDBWatchlistWithCredentials(mediaId: Int, mediaType: MediaType, actionType: ActionType, completion: @escaping (WRError?) -> Void) {
        PersistanceService.retrieveTMDBCredentials { [weak self](result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let credentials):
                guard let credentials = credentials else {
                    debugPrint(WRError.unableToAddToWatchlist.rawValue)
                    completion(.unableToAddToWatchlist)
                    return
                }
                
                self.updateTMDBWatchlist(sessionId: credentials.sessionId, accountId: credentials.accountIdV3, mediaId: mediaId, mediaType: mediaType, actionType: actionType) { (error) in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                        Crashlytics.crashlytics().record(error: error)
                        completion(error)
                        return
                    }
                    completion(nil)
                }
            case .failure(let error):
                debugPrint(error.localizedDescription)
                Crashlytics.crashlytics().record(error: error)
                completion(error)
            }
        }
    }
    
    private func updateTMDBWatchlist(sessionId: String, accountId: Int, mediaId: Int, mediaType: MediaType, actionType: ActionType, completion: @escaping (WRError?) -> Void) {
        let path = TMDB_API.v3.Account.AccountDetailsURL + "/\(accountId)/watchlist?api_key=\(Secrets.MOVIEDB_API_KEY)&session_id=\(sessionId)"
        let parameters: [String : Any] = [
            "media_type": mediaType.rawValue,
            "media_id": mediaId,
            "watchlist": (actionType == .add) ? true : false
        ]
        let headers = ["content-type": "application/json;charset=utf-8"]
        
        RESTful.request(path: path, method: .post, parameters: parameters, headers: headers) { (result) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let response = try decoder.decode(TMDBActionResponse.self, from: data)
                    guard let success = response.success, success == true else {
                        debugPrint("updateTMDBWatchlist success = false")
                        Crashlytics.crashlytics().log("updateTMDBWatchlist success = false")
                        completion(.unableToAddToWatchlist)
                        return
                    }
                    completion(nil)
                } catch {
                    debugPrint(error.localizedDescription)
                    Crashlytics.crashlytics().record(error: error)
                    completion(.unableToAddToWatchlist)
                }
            case .failure(let error):
                debugPrint(error.localizedDescription)
                Crashlytics.crashlytics().record(error: error)
                completion(.unableToAddToWatchlist)
            }
        }
    }
    
    //MARK: FIREBASE
    
    func updateFirebaseWatchlist(userId: String, movieId: Int, actionType: ActionType, completion: @escaping (WRError?) -> Void) {
        //check if already in watch list
        userWatchListDb.whereField("user_id", isEqualTo: userId).whereField("movie_id", isEqualTo: String(movieId)).getDocuments { (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                Crashlytics.crashlytics().record(error: error)
                completion(.unableToAddToWatchlist)
                return
            }
            
            switch actionType {
            case .add:
                //beforer adding movie, make sure the movie is not in watchlist already
                if let snapshot = snapshot, snapshot.documents.count == 0 {
                    userWatchListDb.document().setData(["user_id": userId, "movie_id": String(movieId), "date": Date()]) { (error) in
                        if let error = error {
                            debugPrint(error.localizedDescription)
                            Crashlytics.crashlytics().record(error: error)
                            completion(.unableToAddToWatchlist)
                            return
                        }
                        completion(nil)
                    }
                } else {
                    completion(.unableToAddToWatchlist)
                }
            case .remove:
                for document in snapshot!.documents {
                    document.reference.delete { (error) in
                        if let error = error {
                            debugPrint(error.localizedDescription)
                            Crashlytics.crashlytics().record(error: error)
                            completion(.unableToRemoveFromWatchlist)
                            return
                        }
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func loadFirebaseWatchlist(userId: String, completion: @escaping ([MovieDetail]?) -> Void) {
        var watchlist = [MovieDetail]()
        userWatchListDb.whereField("user_id", isEqualTo: userId).order(by: "date", descending: true).getDocuments { (snapshot, error) in
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                completion(nil)
                return
            } else {
                for document in snapshot!.documents {
                    let data = document.data()
                    let movieId = Int((data["movie_id"] as! NSString).intValue)
                    watchlist.append(MovieDetail(id: movieId))
                }
                completion(watchlist)
            }
        }
    }
}
