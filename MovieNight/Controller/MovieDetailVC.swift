//
//  MovieDetailVC.swift
//  MovieRoom
//
//  Created by Bogdan Dovgopol on 28/7/19.
//  Copyright © 2019 Bogdan Dovgopol. All rights reserved.
//

import UIKit

class MovieDetailVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var movieImg: UIImageView!
    @IBOutlet weak var titleTxt: UILabel!
    @IBOutlet weak var ratingTxt: UILabel!
    @IBOutlet weak var genresTxt: UILabel!
    @IBOutlet weak var descriptionTxt: UITextView!
    
    //Variables
    var movie : Movie!
    
    //change statusbar color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setMovieDetails()
        
        //swipe gasture to dismiss view controller
        let swipeToGoDismiss = UISwipeGestureRecognizer(target: self, action: #selector(dismiss(fromGesture:)))
        view.addGestureRecognizer(swipeToGoDismiss)
    }
    
    func setMovieDetails() {
        //set poster
        if let posterPath = movie.posterPath {
            if let url = URL(string: posterPath) {
                movieImg.kf.setImage(with: url)
            }
        }
        //set title
        titleTxt.text = movie.title
        //set rating
        setRating()
        //set genres
        setGenres()
        //set description
        descriptionTxt.text = movie.overview
    }
    
    func setRating() {
        let movieRatingPercentage = Int(movie.voteAverage * 10)
        var ratingColor : UIColor
        
        //change rating color based on percentage
        if movieRatingPercentage > 70 {
            ratingColor = #colorLiteral(red: 0.5450980392, green: 0.8980392157, blue: 0.5764705882, alpha: 1)
        } else if movieRatingPercentage > 40 {
            ratingColor = #colorLiteral(red: 1, green: 0.9019607843, blue: 0.2588235294, alpha: 1)
        } else {
            ratingColor = #colorLiteral(red: 1, green: 0.2745098039, blue: 0, alpha: 1)
        }
        ratingTxt.textColor = ratingColor
        ratingTxt.text = "\(movieRatingPercentage)%"
    }
    
    func setGenres() {
        if let genres = movie.genreIDs {
            var genreString = ""
            for genre in genres {
                if let genreName = genreList[genre] {
                    genreString += "\(genreName), "
                }
            }

            //remove unnecessary space & comma at the end of the string
            genreString = String(genreString.dropLast(2))
            genresTxt.text = genreString
        }
    }
    
    @objc func dismiss(fromGesture gesture: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
