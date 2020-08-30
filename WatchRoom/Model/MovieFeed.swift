//
//  Movies.swift
//  WatchRoom
//
//  Created by Bogdan on 21/8/20.
//

import Foundation

struct MovieFeed: Codable {
    let totalPages: Int?
    let movies: [MovieResult]?
    
    enum CodingKeys: String, CodingKey {
        case totalPages
        case movies = "results"
    }
}
