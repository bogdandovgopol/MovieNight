//
//  Section.swift
//  WatchRoom
//
//  Created by Bogdan on 24/8/20.
//

import Foundation
import UIKit

struct Section {
    let title: String
    let fontSize: CGFloat?
    let type: SectionType?
    
    enum SectionType {
        case trending
        case playing
        case upcoming
    }
}
