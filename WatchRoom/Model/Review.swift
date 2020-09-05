//
//  Review.swift
//  WatchRoom
//
//  Created by Bogdan on 5/9/20.
//

import Foundation

struct Review: Decodable {
    let id: String?
    let author: String?
    let content: String?
    let url: URL?
}
