//
//  MovieDetail.swift
//  WatchRoom
//
//  Created by Bogdan on 25/8/20.
//

import Foundation

struct MovieDetail: Decodable {
    let title: String?
    let tagline: String?
    let overview: String?
    let popularity: Double?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?
    let releaseDate: String?
    let genres: [Genre]?
}
