//
//  MovieCell.swift
//  WatchRoom
//
//  Created by Bogdan on 21/8/20.
//

import UIKit
import Kingfisher

class MovieCell: UICollectionViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var titleTxt: UILabel!
    @IBOutlet weak var posterImg: UIImageView!
    
    //MARK: Variables
    static let id = "MovieCell"
    static let nib = UINib(nibName: id, bundle: nil)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        updateView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImg.image = UIImage()
    }
    
    func configure(movie: MovieResult) {
        updateMovieCell(title: movie.title, posterPath: movie.posterPath)
    }
    
    func configure(movie: MovieDetail) {
        updateMovieCell(title: movie.title, posterPath: movie.posterPath)
    }
    
    private func updateMovieCell(title: String?, posterPath: String?) {
        titleTxt.text = title
        if let posterPath = posterPath {
            let imgUrl = URL(string: "\(TMDB_API.PosterImageBaseURL)\(posterPath)")
            posterImg.kf.indicatorType = .activity
            posterImg.kf.setImage(
                with: imgUrl,
                placeholder: nil,
                options: [
                    .processor(DownsamplingImageProcessor(size: posterImg.frame.size)),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage,
                    .transition(.fade(0.4))
                ],
                progressBlock: nil)
        }
    }
    
    private func updateView() {
        layer.cornerRadius = 8
    }

}
