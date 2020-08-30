//
//  UIViewExtension.swift
//  WatchRoom
//
//  Created by Bogdan on 20/8/20.
//

import Foundation
import UIKit

extension UIView {
    func applyLinearGradient(firstColor: UIColor, secondColor: UIColor, startPoint: CGPoint, endpoint: CGPoint, locations: [NSNumber], cornerRadius: CGFloat? = nil) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endpoint
        gradientLayer.locations = locations
        gradientLayer.frame = bounds
        
        if let cornerRadius = cornerRadius {
            gradientLayer.cornerRadius = cornerRadius
            gradientLayer.cornerCurve = .continuous
        }
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func applyBorder(borderWidth: CGFloat, cornerRadius: CGFloat, borderColor: UIColor) {
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layer.cornerCurve = .continuous
        layer.borderColor = borderColor.cgColor
    }
    
    func fadeIn(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
            self.alpha = 0
            self.isHidden = false
            UIView.animate(withDuration: duration!,
                           animations: { self.alpha = 1 },
                           completion: { (value: Bool) in
                              if let complete = onCompletion { complete() }
                           }
            )
        }
    
}
