//
//  TMDBCredentials.swift
//  WatchRoom
//
//  Created by Bogdan on 19/9/20.
//

import Foundation

struct TMDBCredentials: Codable {
    let accessToken: String
    let sessionId: String
    let accountIdV3: Int
    let accountIdV4: String
}
