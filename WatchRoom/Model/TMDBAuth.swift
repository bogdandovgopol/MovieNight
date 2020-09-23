//
//  TMDBAuth.swift
//  WatchRoom
//
//  Created by Bogdan on 17/9/20.
//

import Foundation

struct TMDBAuth: Codable {
    var id: Int?
    var success: Bool?
    var requestToken: String?
    var sessionId: String?
    var accessToken: String?
    var accountId: String?
}
