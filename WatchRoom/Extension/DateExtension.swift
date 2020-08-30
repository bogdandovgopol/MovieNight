//
//  DateExtension.swift
//  WatchRoom
//
//  Created by Bogdan on 28/8/20.
//

import Foundation

extension Date {
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
}
