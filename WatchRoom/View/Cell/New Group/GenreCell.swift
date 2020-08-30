//
//  GenreCell.swift
//  WatchRoom
//
//  Created by Bogdan on 29/8/20.
//

import UIKit

class GenreCell: UICollectionViewCell {
    //MARK: Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var nameTxt: UILabel!
    
    //MARK: Variables
    static let id = "GenreCell"
    static let nib = UINib(nibName: id, bundle: nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameTxt.sizeToFit()
        
    }
        

    func configure(genre: Genre) {
        bgView.applyBorder(borderWidth: 0, cornerRadius: self.frame.height / 2, borderColor: UIColor.clear)
        nameTxt.text = genre.name
    }
}
