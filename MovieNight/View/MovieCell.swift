//
//  MovieCell.swift
//  MovieRoom
//
//  Created by Bogdan Dovgopol on 28/7/19.
//  Copyright © 2019 Bogdan Dovgopol. All rights reserved.
//

import UIKit
import Kingfisher

class MovieCell: UICollectionViewCell {
    //Outlets
    @IBOutlet weak var movieImg: UIImageView!
    @IBOutlet weak var movieTitleTxt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(movie: Movie) {
        movieTitleTxt.text = movie.title
        if let posterPath = movie.posterPath {
            if let url = URL(string: posterPath) {
                movieImg.kf.setImage(with: url)
            }
        }
    }
}
