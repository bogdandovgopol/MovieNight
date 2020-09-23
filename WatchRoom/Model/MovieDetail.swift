//
//  MovieDetail.swift
//  WatchRoom
//
//  Created by Bogdan on 25/8/20.
//

import Foundation

struct MovieDetail: Codable {
    var id: Int?
    var title: String?
    var tagline: String?
    var overview: String?
    var popularity: Double?
    var posterPath: String?
    var backdropPath: String?
    var voteAverage: Double?
    var releaseDate: String?
    var runtime: Int?
    var revenue: Int?
    var genres: [Genre]?
}
