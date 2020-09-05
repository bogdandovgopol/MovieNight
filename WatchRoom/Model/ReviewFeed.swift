//
//  ReviewFeed.swift
//  WatchRoom
//
//  Created by Bogdan on 5/9/20.
//

import Foundation

struct ReviewFeed: Decodable {
    let totalPages: Int?
    let reviews: [Review]?
    
    private enum CodingKeys: String, CodingKey {
        case totalPages
        case reviews = "results"
    }
}
