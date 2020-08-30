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
let userWatchListDb = db.collection("watchlist")

//MARK: API Constants
enum TMDB_API {
    static let BaseURL = "https://api.themoviedb.org/3"
    
    enum Movie {
        static let PopularURL = "\(BaseURL)/movie/popular"
        static let UpcomingURL = "\(BaseURL)/movie/upcoming"
        static let NowPlayingURL = "\(BaseURL)/movie/now_playing"
        static let TrendingTodayURL = "\(BaseURL)/trending/movie/day"
        static let SearchURL = "\(BaseURL)/search/movie"
        static let DiscoverURL = "\(BaseURL)/discover/movie"
        static let Details = "\(BaseURL)/movie"
    }
    
    static let PosterImageBaseURL = "https://image.tmdb.org/t/p/w500"
    static let BackdropImageBaseURL = "https://image.tmdb.org/t/p/original"
}

enum UserLocale {
    static let language = Locale.current.languageCode ?? "en"
    static let region = "US"//Locale.current.regionCode ?? ""
}

//MARK: App Constants
enum StoryboardIDs {
    static let MainStoryboard = "Main"
    static let AlertStoryboard = "Alert"
}

enum VCIDs {
    static let AlertVC = "AlertVC"
    static let SignInVC = "SignInVC"
    static let AllMoviesVC = "AllMoviesVC"
    static let MovieDetailVC = "MovieDetailVC"
}

enum CellIDs {
    
}

enum SegueIDs {
    static let ToDetailVC = "toDetailVC"
}
