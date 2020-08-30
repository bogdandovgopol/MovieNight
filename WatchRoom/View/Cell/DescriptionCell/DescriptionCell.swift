//
//  DescriptionCell.swift
//  WatchRoom
//
//  Created by Bogdan on 27/8/20.
//

import UIKit

class DescriptionCell: UICollectionViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var descriptionTxt: UILabel!
    
    // MARK: Variables
    static let id = "DescriptionCell"
    static let nib = UINib(nibName: id, bundle: nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(movie: MovieDetail) {
        descriptionTxt.text = movie.overview ?? "Description not provided"
    }
}
