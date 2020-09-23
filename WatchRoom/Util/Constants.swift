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

// MARK: Errors
enum WRError: String, Error {
    case networkingError = "Unable to complete your request. Please check your internet connection"
    case invalidResponse = "Invalid response from the server. Please try again."
    
    case invalidUrl = "API URL is malformated"
    case unableToComplete = "Unable to complete your request. Please check your internet connection."
    case invalidData = "The data received from the server was invalid. Please try again."
    case invalidJson
    
    case tmdbFailedToLogin = "Unable to login using TMDB account. Please try again."
    case tmdbFailedToSignOut = "Unable to signout from TMDB account. Please try again."
    case tmdbAlreadySignedOut = "You are already signed out."
    case tmdbNoPermission
    case unableToLoadWatchlist = "Unable to load watchlist. Please try again."
    case unableToAddToWatchlist = "Unable to add media to the watchlist. Please try again."
    case unableToRemoveFromWatchlist = "Unable to remove media from the watchlist. Please try again."
    
    case keychainUnableToSaveTMDBCredentials = "Unable to save TMDB credentials. Please try again."
    case keychainUnableToRetrieveTMDBCredentials = "Unable to retrieve TMDB credentials. Please try again."
    case keychainUnableToRemoveTMDBCredentials = "Unable to remove TMDB credentials. Please try again."
    case keychainNoTMDBCredentials = "No TMDB credentials found"
    
    case unableToSignOut = "Unable to sign out. Please try again."
}

//MARK: URL Schemes
enum URLSchemes {
    static let TMDBApprovedLogin = "watchroom://tmdb?approved=true"
}

//MARK: Notification Keys
enum NotificationKeys {
    static let TMDBAuthApprovedKey = NSNotification.Name("TMDBAuthApproved")
}

//MARK: Notification Keys
enum Keys {
    static let AdsRemoved = "ads_removed"
}

//MARK: API Constants
enum TMDB_API {
    static let BaseV3URL = "https://api.themoviedb.org/3"
    static let BaseV4URL = "https://api.themoviedb.org/4"
    
    enum v3 {
        enum Movie {
            static let PopularURL = "\(BaseV3URL)/movie/popular"
            static let UpcomingURL = "\(BaseV3URL)/movie/upcoming"
            static let NowPlayingURL = "\(BaseV3URL)/movie/now_playing"
            static let TrendingTodayURL = "\(BaseV3URL)/trending/movie/day"
            static let SearchURL = "\(BaseV3URL)/search/movie"
            static let DiscoverURL = "\(BaseV3URL)/discover/movie"
            static let Details = "\(BaseV3URL)/movie"
        }
        
        enum Auth {
            static let CreateSessionIdURL = "\(BaseV3URL)/authentication/session/convert/4"
            static let DeleteSessionURL = "\(BaseV3URL)/authentication/session?api_key=\(Secrets.MOVIEDB_API_KEY)"
        }
        
        enum Account {
            static let AccountDetailsURL = "\(BaseV3URL)/account"
        }
    }
    
    enum v4 {
        enum Auth {
            static let CreateRequestTokenURL = "\(BaseV4URL)/auth/request_token"
            static let RequestTokenRedirectURL = "https://www.themoviedb.org/auth/access?request_token="
            static let AccessTokenURL = "\(BaseV4URL)/auth/access_token"
        }
        
        enum Account {
            static let AccountDetailsURL = "\(BaseV4URL)/account"
        }
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
    static let DiscoverVC = "DiscoverVC"
    static let AllMoviesVC = "AllMoviesVC"
    static let MovieDetailVC = "MovieDetailVC"
    static let ReviewsVC = "ReviewsVC"
    static let SettingsVC = "SettingsVC"
}

enum CellIDs {
    
}

enum SegueIDs {
    static let ToDetailVC = "toDetailVC"
}
