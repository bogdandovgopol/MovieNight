//
//  Movies.swift
//  WatchRoom
//
//  Created by Bogdan on 21/8/20.
//

import Foundation

struct MovieFeed: Decodable {
    let totalPages: Int = 0
    let movies: [MovieResult]?
    
    enum CodingKeys: String, CodingKey {
        case movies = "results"
    }
}
