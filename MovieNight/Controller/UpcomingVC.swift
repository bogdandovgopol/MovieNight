//
//  UpcomingVC.swift
//  MovieRoom
//
//  Created by Bogdan Dovgopol on 28/7/19.
//  Copyright © 2019 Bogdan Dovgopol. All rights reserved.
//

import UIKit

class UpcomingVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Variables
    var movies = [Movie]()
    var selectedMovie: Movie!
    
    //change statusbar color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupCollectionView()
        loadMovies()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: IDENTIFIERS.MOVIE_CELL, bundle: nil), forCellWithReuseIdentifier: IDENTIFIERS.MOVIE_CELL)
    }
    
    func loadMovies() {
        self.activityIndicator.startAnimating()
        MovieService.getMovies(url: TMDB.UPCOMING_BASEURL) { (result, error) in
            //check if there was an error
            if let error = error {
                self.activityIndicator.stopAnimating()
                print(error)
                return
            }
            
            //populate movies array
            for movie in result! {
                self.movies.append(movie)
            }
            
            //reload collectionview data
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
        
    }
}

extension UpcomingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IDENTIFIERS.MOVIE_CELL, for: indexPath) as? MovieCell {
            cell.configureCell(movie: movies[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMovie = movies[indexPath.item]
        performSegue(withIdentifier: SEGUAES.UPCOMING_TO_DETAIL, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUAES.UPCOMING_TO_DETAIL {
            if let destination = segue.destination as? MovieDetailVC {
                destination.movie = selectedMovie
            }
        }
    }
}
