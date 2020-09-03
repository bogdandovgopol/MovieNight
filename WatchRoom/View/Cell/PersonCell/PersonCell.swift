//
//  PersonCell.swift
//  WatchRoom
//
//  Created by Bogdan on 27/8/20.
//

import UIKit
import Kingfisher

class PersonCell: UICollectionViewCell {
    // MARK: Outltets
    @IBOutlet weak var personImg: UIImageView!
    @IBOutlet weak var nameTxt: UILabel!
    @IBOutlet weak var characterTxt: UILabel!
    
    // MARK: Variables
    static let id = "PersonCell"
    static let nib = UINib(nibName: id, bundle: nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        personImg.image = UIImage()
    }
    
    func configure(person: Person) {
        nameTxt.text = person.name
        characterTxt.text = person.character
        
        if let profilePath = person.profilePath {
            let imgUrl = URL(string: "\(TMDB_API.PosterImageBaseURL)\(profilePath)")
            personImg.kf.indicatorType = .activity
            personImg.kf.setImage(
                with: imgUrl,
                placeholder: UIImage(),
                options: [
                    .processor(DownsamplingImageProcessor(size: personImg.frame.size)),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage,
                    .transition(.fade(0.4))
                ],
                progressBlock: nil)
        }
//        updateView()
    }
    
    private func updateView() {
//        personImg.layer.borderWidth = 1.0
//        personImg.layer.masksToBounds = false
//        personImg.layer.borderColor = UIColor.white.cgColor
        personImg.layer.cornerRadius = personImg.frame.size.width / 2
        personImg.layer.cornerCurve = .continuous
        
//        personImg.clipsToBounds = true
    }

}
