//
//  WatchListVC.swift
//  WatchRoom
//
//  Created by Bogdan on 30/8/20.
//
import UIKit
import FirebaseCrashlytics
import FirebaseAuth

class WatchListVC: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK: Variables
    var movies = [MovieDetail]()
    var selectedMovie: MovieDetail!
    var page = 1
    var isLoadingMoreMovies = false
    var hasMoreMovies = true
    var signInType: SignInType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        configureCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator.startAnimating()
        loadWatchlistIfSignedIn()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
            self.collectionView.fadeIn(0.5)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.isHidden = true
        self.page = 1
        self.hasMoreMovies = true
        movies.removeAll()
        collectionView.reloadData()
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
        let padding: CGFloat = 16
        
        //define item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //configurate item
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: padding, trailing: padding)
        
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
    
    func loadWatchlistIfSignedIn() {
        isUserSignedIn { [weak self](type) in
            guard let self = self else { return }
            guard let type = type else {
                self.presentSignInVC()
                self.tabBarController?.selectedIndex = 0
                return
            }
            
            self.signInType = type
            
            switch type {
            case .firebase:
                self.loadWatchlist(type: .firebase, page: self.page)
            case .tmdb:
                self.loadWatchlist(type: .tmdb, page: self.page)
            }
        }
    }
    
    func loadWatchlist(type: SignInType, page: Int) {
        activityIndicator.startAnimating()
        isLoadingMoreMovies = true
        WatchlistService.shared.loadWatchlist(with: type, page: page) { [weak self](movies) in
            guard let self = self else { return }
            if type == .tmdb && movies.count < 20 { self.hasMoreMovies = false }
            
            DispatchQueue.main.async {
                var indexPaths = [IndexPath]()
                for item in 0..<movies.count {
                    let indexPath = IndexPath(row: item + self.movies.count, section: 0)
                    indexPaths.append(indexPath)
                }
                self.collectionView.performBatchUpdates({
                    self.movies.append(contentsOf: movies)
                    self.collectionView.insertItems(at: indexPaths)
                    
                }) { (_) in
                    self.isLoadingMoreMovies = false
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
}

//MARK: UICollectionViewDelegate implementation
extension WatchListVC: UICollectionViewDelegate {
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
        if indexPath.item == movies.count - 3 {
            if signInType == .tmdb {
                guard hasMoreMovies, !isLoadingMoreMovies else { return }
                
                page += 1
                loadWatchlist(type: .tmdb, page: self.page)
            }
        }
    }
}

//MARK: UICollectionViewDataSource implementation
extension WatchListVC: UICollectionViewDataSource {
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
extension WatchListVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.id, for: indexPath) as! SectionHeader
            
            switch indexPath.section {
            case 0:
                header.configure(section: Section(title: "My Watchlist", fontSize: nil, type: nil), delegate: nil)
            default: break
            }
            return header
        default: return UICollectionReusableView()
        }
    }
}

//MARK: UITabBarControllerDelegate implementation
extension WatchListVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedViewController == self {
            collectionView.setContentOffset(.zero, animated: true)
        }
        
    }
}
