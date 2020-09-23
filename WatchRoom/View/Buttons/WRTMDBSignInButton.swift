//
//  WRTMDBSignInButton.swift
//  WatchRoom
//
//  Created by Bogdan on 18/9/20.
//

import UIKit

class WRTMDBSignInButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(title: String, backgroundColor: UIColor) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
        setTitle(title, for: .normal)
        configure()
    }
    
    private func configure() {
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        layer.cornerRadius = 7
        translatesAutoresizingMaskIntoConstraints = false
    }
}
