//
//  TMDBActionResponse.swift
//  WatchRoom
//
//  Created by Bogdan on 22/9/20.
//

import Foundation

struct TMDBActionResponse: Codable {
    var success: Bool?
    var statusCode: Int?
    var statusMessage: String?
}
