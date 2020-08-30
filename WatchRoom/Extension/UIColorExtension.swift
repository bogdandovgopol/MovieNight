//
//  UIColorExtension.swift
//  WatchRoom
//
//  Created by Bogdan on 20/8/20.
//

import Foundation
import UIKit

extension UIColor {
    // Load image using rbg/hex
    // source https://medium.com/ios-os-x-development/ios-extend-uicolor-with-custom-colors-93366ae148e6
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    // Check if the color is light or dark, as defined by the injected lightness threshold.
    func isLight(threshold: Float = 0.7) -> Bool? {
        let originalCGColor = self.cgColor
        
        // Convert to the RGB colorspace. UIColor.white / UIColor.black are greyscale and not RGB.
        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        
        guard let components = RGBCGColor?.components else {
            return nil
        }
        
        guard components.count >= 3 else {
            return nil
        }
        
        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }
    
    //MARK: Custom colors
    struct CustomColor {
        static let Purpure = UIColor(named: "PurpureColor") ?? UIColor(netHex: 0xEF4D88)
        static let Blue = UIColor(named: "BlueColor") ?? UIColor(netHex: 0x4E51FF)
    }
}
