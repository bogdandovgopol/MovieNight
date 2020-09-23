//
//  StringExtension.swift
//  WatchRoom
//
//  Created by Bogdan on 21/9/20.
//

import Foundation

extension String {
    func convertToDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = .current
        
        return dateFormatter.date(from: self)
    }
}
