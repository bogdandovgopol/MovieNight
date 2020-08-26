//
//  Movie.swift
//  WatchRoom
//
//  Created by Bogdan on 21/8/20.
//

import Foundation

struct MovieResult: Codable {
    let id: Int?
    let popularity: Double?
    let posterPath: String?
    let backdropPath: String?
    let title: String?
    let voteAverage: Double?
    let overview: String?
    let releaseDate: String?
}
