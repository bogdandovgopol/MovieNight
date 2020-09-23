//
//  SKProductExtension.swift
//  WatchRoom
//
//  Created by Bogdan on 23/9/20.
//

import Foundation
import StoreKit

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
