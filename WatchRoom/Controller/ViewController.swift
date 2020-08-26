//
//  ViewController.swift
//  WatchRoom
//
//  Created by Bogdan on 19/8/20.
//

import UIKit
import FirebaseCrashlytics

class DiscoverVC: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //MARK: Variables
    var trendingMovies = [MovieResult]()
    var trendingMoviesPage = 1
    var nowPlayingMovies = [MovieResult]()
    var nowPlayingMoviesPage = 1
    var upcomingMovies = [MovieResult]()
    var upcomingMoviesPage = 1
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.isUserSignedIn()
        loadMovies()
        configureCollectionView()
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
                return self.trendingMoviesSection()
            case 1:
                return self.nowPlayingMoviesSection()
            case 2:
                return self.upcomingMoviesSection()
            default:
                return self.trendingMoviesSection()
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        layout.configuration = config
        return layout
    }
    
    //MARK: CollectionViewLayout sections
    //MARK: popularMovies section
    func trendingMoviesSection() -> NSCollectionLayoutSection {
        let inset = CGFloat(16)
        let posterHeight = CGFloat(380)
        let posterWidth = CGFloat(posterHeight / 1.5) + inset
        
        //define item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //configurate item
        item.contentInsets.trailing = inset
        
        //define group
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(posterWidth), heightDimension: .absolute(posterHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
        
        //define section
        let section = NSCollectionLayoutSection(group: group)
        
        //configure section
        section.contentInsets.leading = 16
        section.orthogonalScrollingBehavior = .groupPaging
        
        //configure header
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(45))
        section.boundarySupplementaryItems = [
            .init(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        ]
        
        return section
    }
    
    //MARK: nowPlayingMovies section
    func nowPlayingMoviesSection() -> NSCollectionLayoutSection {
        let inset = CGFloat(12)
        let posterHeight = CGFloat(220)
        let posterWidth = CGFloat(posterHeight / 1.5) + inset
        
        //define item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //configurate item
        item.contentInsets.trailing = inset
        
        //define group
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(posterWidth), heightDimension: .absolute(posterHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        
        //define section
        let section = NSCollectionLayoutSection(group: group)
        
        //configure section
        section.contentInsets.leading = 16
        section.orthogonalScrollingBehavior = .continuous
        
        //configure header
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(45))
        section.boundarySupplementaryItems = [
            .init(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        ]
        
        return section
    }
    
    //MARK: upcomingMovies section
    func upcomingMoviesSection() -> NSCollectionLayoutSection {
        let inset = CGFloat(12)
        let posterHeight = CGFloat(220)
        let posterWidth = CGFloat(posterHeight / 1.5) + inset
        
        //define item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //configurate item
        item.contentInsets.trailing = inset
        
        //define group
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(posterWidth), heightDimension: .absolute(posterHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        
        //define section
        let section = NSCollectionLayoutSection(group: group)
        
        //configure section
        section.contentInsets.leading = 16
        section.orthogonalScrollingBehavior = .continuous
        
        //configure header
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(45))
        section.boundarySupplementaryItems = [
            .init(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        ]
        
        return section
    }
    
    //MARK: Load movies
    func loadMovies() {
        loadTrendingMovies(page: 1, section: 0)
        loadNowPlayingMovies(page: 1, section: 1)
        loadUpcomingMovies(page: 1, section: 2)
    }
    
    //MARK: Load popular movies
    func loadTrendingMovies(page: Int, section: Int) {
        let path = TMDB_API.Movies.TrendingTodayURL
        let parameters = [
            "api_key": Secrets.MOVIEDB_API_KEY,
            "page": String(page),
            "language": UserLocale.language,
            "region": "US"
        ]
        
        MovieService.shared.getMovies(path: path, parameters: parameters) { [weak self](result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    Crashlytics.crashlytics().record(error: error)
                    break
                case .success(let movies):
                    if page > 1 {
                        var indexPaths = [IndexPath]()
                        for item in 0..<movies.count {
                            let indexPath = IndexPath(row: item + self.trendingMovies.count, section: section)
                            indexPaths.append(indexPath)
                        }
                        self.collectionView.performBatchUpdates({
                            self.trendingMovies.append(contentsOf: movies)
                            self.collectionView.insertItems(at: indexPaths)
                            
                        }, completion: nil)
                        
                    } else {
                        self.trendingMovies.append(contentsOf: movies)
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    //MARK: Now playing movies
    func loadNowPlayingMovies(page: Int, section: Int) {
        let path = TMDB_API.Movies.NowPlayingURL
        let parameters = [
            "api_key": Secrets.MOVIEDB_API_KEY,
            "page": String(page),
            "language": UserLocale.language,
            "region": UserLocale.region
        ]
        
        MovieService.shared.getMovies(path: path, parameters: parameters) { [weak self](result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    Crashlytics.crashlytics().record(error: error)
                    break
                case .success(let movies):
                    if page > 1 {
                        var indexPaths = [IndexPath]()
                        for item in 0..<movies.count {
                            let indexPath = IndexPath(row: item + self.nowPlayingMovies.count, section: section)
                            indexPaths.append(indexPath)
                        }
                        self.collectionView.performBatchUpdates({
                            self.nowPlayingMovies.append(contentsOf: movies)
                            self.collectionView.insertItems(at: indexPaths)
                            
                        }, completion: nil)
                        
                    } else {
                        self.nowPlayingMovies.append(contentsOf: movies)
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    //MARK: Upcoming movies
    func loadUpcomingMovies(page: Int, section: Int) {
        let path = TMDB_API.Movies.UpcomingURL
        let parameters = [
            "api_key": Secrets.MOVIEDB_API_KEY,
            "page": String(page),
            "language": UserLocale.language,
            "region": "US"
        ]
        
        MovieService.shared.getMovies(path: path, parameters: parameters) { [weak self](result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    Crashlytics.crashlytics().record(error: error)
                    break
                case .success(let movies):
                    if page > 1 {
                        var indexPaths = [IndexPath]()
                        for item in 0..<movies.count {
                            let indexPath = IndexPath(row: item + self.upcomingMovies.count, section: section)
                            indexPaths.append(indexPath)
                        }
                        self.collectionView.performBatchUpdates({
                            self.upcomingMovies.append(contentsOf: movies)
                            self.collectionView.insertItems(at: indexPaths)
                            
                        }, completion: nil)
                        
                    } else {
                        self.upcomingMovies.append(contentsOf: movies)
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
}

//MARK: UICollectionViewDelegate implementation
extension DiscoverVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

//MARK: UICollectionViewDataSource implementation
extension DiscoverVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return trendingMovies.count
        case 1: return nowPlayingMovies.count
        case 2: return upcomingMovies.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.id, for: indexPath) as! MovieCell
            cell.configure(movie: trendingMovies[indexPath.row])
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.id, for: indexPath) as! MovieCell
            cell.configure(movie: nowPlayingMovies[indexPath.row])
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.id, for: indexPath) as! MovieCell
            cell.configure(movie: upcomingMovies[indexPath.row])
            return cell
        default: return UICollectionViewCell()
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            debugPrint("0 - \(indexPath.item)")
            if indexPath.row == trendingMovies.count - 1 {
                print("Section 0, Row \(indexPath.row) - Loading more trending movies...")
                trendingMoviesPage += 1
                loadTrendingMovies(page: trendingMoviesPage, section: indexPath.section)
            }
            break
        case 1:
            debugPrint("1 - \(indexPath.item)")
            if indexPath.row == nowPlayingMovies.count - 1 {
                print("Section 1, Row \(indexPath.row) - Loading more now streaming movies...")
                nowPlayingMoviesPage += 1
                loadNowPlayingMovies(page: nowPlayingMoviesPage, section: indexPath.section)
            }
            break
        case 2:
            debugPrint("2 - \(indexPath.item)")
            if indexPath.row == upcomingMovies.count - 1 {
                print("Section 2, Row \(indexPath.row) - Loading more upcoming movies...")
                upcomingMoviesPage += 1
                loadUpcomingMovies(page: upcomingMoviesPage, section: indexPath.section)
            }
            break
        default: break
        }
    }
    
}

//MARK: UICollectionViewDelegateFlowLayout implementation
extension DiscoverVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.id, for: indexPath) as! SectionHeader
            switch indexPath.section {
            case 0:
                header.configure(title: "Trending today")
            case 1:
                header.configure(title: "Now streaming")
            case 2:
                header.configure(title: "Coming soon")
            default: break
            }
            return header
        default: return UICollectionReusableView()
        }
    }
}
