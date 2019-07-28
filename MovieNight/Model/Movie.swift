//
//  Movie.swift
//  MovieRoom
//
//  Created by Bogdan Dovgopol on 27/7/19.
//  Copyright © 2019 Bogdan Dovgopol. All rights reserved.
//

import Foundation

struct Movie {
    var id: Int?
    var title: String?
    var overview: String?
    var posterPath: String?
    var voteAverage: Double = 0
    var genreIDs: [Int]?
    
    init?(json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let overview = json["overview"] as? String else {
                return nil
        }
        
        self.id = id
        self.title = title
        self.overview = overview
        
        if let voteAverage = json["vote_average"] as? Double {
            self.voteAverage = voteAverage
        }
        
        if let genreIDs = json["genre_ids"] as? [Int] {
            self.genreIDs = genreIDs
        }
        
        if let posterPath = json["poster_path"] as? String {
            self.posterPath = TMDB.POSTER_BASEURL + posterPath
        }
    }
}
