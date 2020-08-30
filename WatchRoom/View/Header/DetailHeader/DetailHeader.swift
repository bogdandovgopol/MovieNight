//
//  DetailHeader.swift
//  WatchRoom
//
//  Created by Bogdan on 27/8/20.
//

import UIKit
import Kingfisher

class DetailHeader: UICollectionReusableView {
    //MARK: Outlets
    @IBOutlet weak var backdropImg: UIImageView!
    @IBOutlet weak var titleTxt: UILabel!
    
    // MARK: Variables
    static let id = "DetailHeader"
    static let nib = UINib(nibName: id, bundle: nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(movie: MovieDetail?) {
        guard let movie = movie else { return }
        
        titleTxt.text = movie.title
        if let backdropPath = movie.backdropPath {
            let imgUrl = URL(string: "\(TMDB_API.BackdropImageBaseURL)\(backdropPath)")
            backdropImg.kf.indicatorType = .activity
            backdropImg.kf.setImage(
                with: imgUrl,
                placeholder: nil,
                options: [
                    .processor(DownsamplingImageProcessor(size: backdropImg.frame.size)),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage,
                    .transition(.fade(0.4))
                ],
                progressBlock: nil)
        }
    }
    
}
