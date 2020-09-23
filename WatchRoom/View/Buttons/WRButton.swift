//
//  WRButton.swift
//  WatchRoom
//
//  Created by Bogdan on 29/8/20.
//

import UIKit

class WRButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    func setupButton() {        
        setGradientBorder()
    }
    
    
    func setGradientBorder() {
        clipsToBounds = true
        layer.cornerRadius = frame.height/2
        layer.cornerCurve = .continuous
        layer.backgroundColor = UIColor.clear.cgColor
        
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: frame.size)
        gradient.colors = [UIColor.CustomColor.Purpure.cgColor, UIColor.CustomColor.Blue.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.locations = [0,1]

        let shape = CAShapeLayer()
        shape.lineWidth = 4
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        gradient.mask = shape
        
        layer.addSublayer(gradient)
    }
    
    func fillWithGradient() {
        self.applyLinearGradient(firstColor: UIColor.CustomColor.Purpure, secondColor: UIColor.CustomColor.Blue, startPoint: CGPoint(x: 0.0, y: 0.5), endpoint: CGPoint(x: 1.0, y: 0.5), locations: [0,1], cornerRadius: self.frame.size.height / 2)
    }
    
    func removeGradientLayer() {
        let gradientLatersCount = ((layer.sublayers?.compactMap { $0 as? CAGradientLayer })?.count) ?? 0
        if gradientLatersCount > 1 {
            if let gradient = (layer.sublayers?.compactMap { $0 as? CAGradientLayer })?.first {
                gradient.removeFromSuperlayer()
            }
        }
    }
    
    
//    override var isSelected: Bool {
//        didSet {
//            self.applyLinearGradient(firstColor: UIColor.CustomColor.Blue, secondColor: UIColor.CustomColor.Purpure, startPoint: CGPoint(x: 0.0, y: 0.5), endpoint: CGPoint(x: 1.0, y: 0.5), locations: [0,1], cornerRadius: self.frame.height / 2)
//        }
//    }
}
