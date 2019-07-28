//
//  Constants.swift
//  MovieRoom
//
//  Created by Bogdan Dovgopol on 27/7/19.
//  Copyright © 2019 Bogdan Dovgopol. All rights reserved.
//

import Foundation

struct TMDB {
    static let NOW_PLAYING_BASEURL = "https://api.themoviedb.org/3/movie/now_playing"
    static let UPCOMING_BASEURL = "https://api.themoviedb.org/3/movie/upcoming"
    static let POPULAR_BASEURL = "https://api.themoviedb.org/3/movie/popular"
    static let POSTER_BASEURL = "https://image.tmdb.org/t/p/w780"
}

struct IDENTIFIERS {
    static let MOVIE_CELL = "MovieCell"
}

struct SEGUAES {
    static let NOW_PLAYING_TO_DETAIL = "nowPlayingToDetail"
    static let UPCOMING_TO_DETAIL = "upcomingToDetail"
}
