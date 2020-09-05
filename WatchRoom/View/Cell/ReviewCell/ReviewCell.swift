//
//  ReviewCell.swift
//  WatchRoom
//
//  Created by Bogdan on 5/9/20.
//

import UIKit

class ReviewCell: UICollectionViewCell {
    //MARK: Outlets
    @IBOutlet weak var authorTxt: UILabel!
    @IBOutlet weak var reviewTxt: UILabel!
    
    
    //MARK: Variables
    static let id = "ReviewCell"
    static let nib = UINib(nibName: id, bundle: nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(review: Review) {
        authorTxt.text = review.author
        reviewTxt.text = review.content
    }
}
