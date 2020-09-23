//
//  AllMoviesVC.swift
//  WatchRoom
//
//  Created by Bogdan on 24/8/20.
//

import UIKit

class AllMoviesVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Variables
    var section: Section!
    var movieFeed: MovieFeed!
    var movies = [MovieDetail]()
    var moviesPage = 1
    var selectedMovie: MovieDetail!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        configureCollectionView()
        loadMovies(page: 1, section: 0)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.activityIndicator.stopAnimating()
            self.collectionView.fadeIn(0.5)
        }
    }
    
    //MARK: CollectionView configuration
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.allowsMultipleSelection = true
        collectionView.contentInset.bottom = 16
        
        collectionView.register(MovieCell.nib, forCellWithReuseIdentifier: MovieCell.id)
        collectionView.register(SectionHeader.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.id)
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionNumber, _) -> NSCollectionLayoutSection? in
            switch sectionNumber {
            case 0:
                return self.moviesSection()
            default:
                return self.moviesSection()
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        layout.configuration = config
        return layout
    }
    
    //MARK: CollectionViewLayout sections
    
    /// - Tag: Movies section
    func moviesSection() -> NSCollectionLayoutSection {
        
        //define item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //configurate item
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 16)
        
        //define group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
        
        
        //define section
        let section = NSCollectionLayoutSection(group: group)
        
        //configure section
        section.contentInsets.leading = 16
        
        //        //configure header
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(45))
        section.boundarySupplementaryItems = [
            .init(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        ]
        
        
        return section
    }
    
    func loadMovies(page: Int, section: Int) {
        var path = ""
        switch self.section.type {
        case .trending:
            path = TMDB_API.v3.Movie.TrendingTodayURL
        case .playing:
            path = TMDB_API.v3.Movie.NowPlayingURL
        case .upcoming:
            path = TMDB_API.v3.Movie.UpcomingURL
        case .none:
            path = ""
        }
        
        if path.isEmpty {
            return
        }
        
        let parameters = [
            "api_key": Secrets.MOVIEDB_API_KEY,
            "page": String(page),
            "language": UserLocale.language,
            "include_adult": "false",
            "region": UserLocale.region
        ]
        
        MovieService.shared.getMovies(path: path, parameters: parameters) { [weak self](result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    self.presentSimpleAlert(withTitle: "Something went wrong", message: error.rawValue)
                case .success(let feed):
                    self.movieFeed = feed
                    if let movies = feed.movies, movies.count > 0 {
                        if page > 1 {
                            var indexPaths = [IndexPath]()
                            for item in 0..<movies.count {
                                let indexPath = IndexPath(row: item + self.movies.count, section: section)
                                indexPaths.append(indexPath)
                            }
                            self.collectionView.performBatchUpdates({
                                self.movies.append(contentsOf: movies)
                                self.collectionView.insertItems(at: indexPaths)
                                
                            }, completion: nil)
                            
                        } else {
                            self.movies.append(contentsOf: movies)
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
}

//MARK: UICollectionViewDelegate implementation
extension AllMoviesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            selectedMovie = movies[indexPath.item]
        default:break
        }
        
        let storyboard = UIStoryboard(name: StoryboardIDs.MainStoryboard, bundle: nil)
        let movieDetailVC = storyboard.instantiateViewController(withIdentifier: VCIDs.MovieDetailVC) as! MovieDetailVC
        movieDetailVC.id = selectedMovie.id
        present(movieDetailVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == movies.count - 2 {
            if moviesPage < movieFeed.totalPages ?? 0 {
                moviesPage += 1
                loadMovies(page: moviesPage, section: 0)
            }
        }
    }
}

//MARK: UICollectionViewDataSource implementation
extension AllMoviesVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return movies.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.id, for: indexPath) as! MovieCell
            cell.configure(movie: movies[indexPath.item])
            return cell
        default: return UICollectionViewCell()
        }
    }
}

//MARK: UICollectionViewDelegateFlowLayout implementation
extension AllMoviesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.id, for: indexPath) as! SectionHeader
            
            switch indexPath.section {
            case 0:
                header.configure(section: self.section, delegate: nil)
            default: break
            }
            return header
        default: return UICollectionReusableView()
        }
    }
}
