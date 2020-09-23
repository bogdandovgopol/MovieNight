//
//  Movies.swift
//  WatchRoom
//
//  Created by Bogdan on 21/8/20.
//

import Foundation

struct MovieFeed: Codable {
    var totalPages: Int?
    var movies: [MovieDetail]?
    
    enum CodingKeys: String, CodingKey {
        case totalPages
        case movies = "results"
    }
}
