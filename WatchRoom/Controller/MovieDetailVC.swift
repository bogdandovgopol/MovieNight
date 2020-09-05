//
//  MovieDetailVC.swift
//  WatchRoom
//
//  Created by Bogdan on 23/8/20.
//

import UIKit
import FirebaseAuth
import FirebaseCrashlytics
import Kingfisher

class MovieDetailVC: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleView: GradientView!
    
    @IBOutlet weak var backdropImg: UIImageView!
    
    @IBOutlet weak var titleTxt: UILabel!
    @IBOutlet weak var releaseDateTxt: UILabel!
    @IBOutlet weak var ratingTxt: UILabel!
    @IBOutlet weak var overviewTxt: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var reviewsBtn: UIButton!
    @IBOutlet weak var addToWatchListBtn: WRButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addToWatchListIndicator: UIActivityIndicatorView!
    
    //MARK: Variables
    var id: Int!
    var isInWatchList = false
    var movie: MovieDetail?
    var credits: Credits?
    var reviewFeed: ReviewFeed?
    var watchList = [Int]()
    var btnLoading = false
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        scrollView.contentInsetAdjustmentBehavior = .never
        configureCollectionView()
        loadMovieDetails(id: id)
        loadMovieCredits(id: id)
        loadWatchList()
        loadMovieReviews(id: id, page: 1)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.activityIndicator.stopAnimating()
            self.scrollView.fadeIn(0.5)
        }
        
        ReviewManager.shared.checkAppOpenCountAndProvideReview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    
    //MARK: UI
    override var preferredStatusBarStyle: UIStatusBarStyle {
        //change statusbar color based on backdrop image
        let averageColor = backdropImg.image?.averageColor ?? UIColor.black
        if let isColorLight = averageColor.isLight(), isColorLight == true {
            return .darkContent
        }
        
        return .lightContent
    }
    
    func updateUI() {
        //title color based on background
        let averageColor = backdropImg.image?.averageColor ?? UIColor.black
        if let isColorLight = averageColor.isLight(), isColorLight == true {
            titleTxt.textColor = UIColor.black
        } else {
            titleTxt.textColor = UIColor.white
        }
    }
    
    func updateMovieUI() {
        guard let movie = movie else { return }
        
        titleTxt.text = movie.title
        ratingTxt.text = "\(movie.voteAverage ?? 0)"
        overviewTxt.text = movie.overview ?? "No overview provided"
        
        if let releaseDate = movie.releaseDate {
            releaseDateTxt.text = releaseDate.toString(format: "d MMMM y")
        }
        
        if let backdropPath = movie.backdropPath {
            let imgUrl = URL(string: "\(TMDB_API.BackdropImageBaseURL)\(backdropPath)")
            backdropImg.kf.indicatorType = .activity
            backdropImg.kf.setImage(
                with: imgUrl,
                placeholder: nil,
                options: [
                    .processor(DownsamplingImageProcessor(size: backdropImg.frame.size)),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage
                ],
                progressBlock: nil)
        }
        
        self.collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    //MARK: CollectionView configuration
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.allowsMultipleSelection = true
        collectionView.contentInset.bottom = 16
        
        collectionView.register(GenreCell.nib, forCellWithReuseIdentifier: GenreCell.id)
        collectionView.register(PersonCell.nib, forCellWithReuseIdentifier: PersonCell.id)
        
        collectionView.register(SectionHeader.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.id)
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionNumber, _) -> NSCollectionLayoutSection? in
            switch sectionNumber {
            case 0:
                return self.genreSection()
            case 1:
                return self.creditsSection()
            default:
                return self.genreSection()
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        layout.configuration = config
        return layout
    }
    
    /// - Tag: genre section
    func genreSection() -> NSCollectionLayoutSection {
        //define item
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(1), heightDimension: .absolute(40))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //define group
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        
        
        //define section
        let section = NSCollectionLayoutSection(group: group)
        
        //configure section
        section.interGroupSpacing = 10
        section.contentInsets.leading = 16
        section.contentInsets.trailing = 16
        section.orthogonalScrollingBehavior = .continuous
        
        //configure header
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
        section.boundarySupplementaryItems = [
            .init(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        ]
        
        return section
    }
    
    /// - Tag: credits section
    func creditsSection() -> NSCollectionLayoutSection {        
        //define item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //configurate item
        item.contentInsets.trailing = 12
        
        //define group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/4), heightDimension: .estimated(200))
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
    
    //MARK: Get movie details
    func loadMovieDetails(id: Int) {
        let path = "\(TMDB_API.Movie.Details)/\(id)"
        let parameters = [
            "api_key": Secrets.MOVIEDB_API_KEY,
            "language": UserLocale.language
        ]
        
        MovieService.shared.getMovie(path: path, parameters: parameters) { [weak self](result) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    Crashlytics.crashlytics().record(error: error)
                case .success(let movie):
                    self.movie = movie
                    self.updateMovieUI()
                }
            }
        }
    }
    
    //MARK: Get credits
    func loadMovieCredits(id: Int) {
        let parameters = [
            "api_key": Secrets.MOVIEDB_API_KEY,
        ]
        
        CreditsService.shared.getMovieCredits(movieId: id, parameters: parameters) { [weak self](result) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    Crashlytics.crashlytics().record(error: error)
                case .success(let credits):
                    self.credits = credits
                    self.collectionView.reloadSections(IndexSet(integer: 1))
                }
            }
        }
    }
    
    //MARK: Get reviews
    func loadMovieReviews(id: Int, page: Int) {
        let parameters = [
            "api_key": Secrets.MOVIEDB_API_KEY,
            "language": UserLocale.language,
            "page": String(page)
        ]
        
        ReviewService.shared.getMovieReviews(movieId: id, parameters: parameters) { [weak self](result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    Crashlytics.crashlytics().record(error: error)
                case .success(let feed):
                    self.reviewFeed = feed
                    self.reviewsBtn.setTitle("\(feed.reviews?.count ?? 0) reviews", for: .normal)
                }
            }
        }
    }
    
    //MARK: Watchlist logic
    func loadWatchList() {
        if let userId = Auth.auth().currentUser?.uid {
            UserService.shared.getWatchList(userId: userId) { (watchList) in
                if let watchList = watchList {
                    self.watchList.append(contentsOf: watchList)
                    self.checkIfAlreadyInWatchList()
                }
            }
        }
    }
    
    func checkIfAlreadyInWatchList() {
        if watchList.contains(id) == true {
            addToWatchListBtn.setTitle("In Watchlist", for: .normal)
            addToWatchListBtn.setTitleColor(UIColor.white, for: .normal)
            addToWatchListBtn.fillWithGradient()
            isInWatchList = true
        } else {
            addToWatchListBtn.setTitle("Add to Watchlist", for: .normal)
            addToWatchListBtn.setTitleColor(UIColor(named: "HeadlineColor") ?? UIColor.gray, for: .normal)
            addToWatchListBtn.removeGradientLayer()
            isInWatchList = false
        }
    }
    
    //MARK: Buttons implementation
    /// - Tag: onAddToWatchListPressed
    @IBAction func onAddToWatchListPressed(_ sender: Any) {
        if btnLoading == false {
            addToWatchListIndicator.startAnimating()
            btnLoading = true
            self.isUserSignedIn { [weak self](signed) in
                guard let self = self else {return}
                
                if signed == true {
                    if self.isInWatchList == false {
                        UserService.shared.addToWatchList(userId: Auth.auth().currentUser!.uid, movieId: self.id) { [weak self](finished) in
                            guard let self = self else {return}
                            if finished == true {
                                self.watchList.append(self.id)
                                self.checkIfAlreadyInWatchList()
                                self.addToWatchListIndicator.stopAnimating()
                                self.btnLoading = false
                            }
                        }
                    } else {
                        UserService.shared.removeFromWatchList(userId:  Auth.auth().currentUser!.uid, movieId: self.id) { [weak self](finished) in
                            guard let self = self else {return}
                            if finished == true {
                                self.watchList = self.watchList.filter {$0 != self.id}
                                self.checkIfAlreadyInWatchList()
                                self.addToWatchListIndicator.stopAnimating()
                                self.btnLoading = false
                            }
                        }
                    }
                } else {
                    self.addToWatchListIndicator.stopAnimating()
                    self.btnLoading = false
                }
            }
        }
    }
    
    /// - Tag: onReviewsPressed
    @IBAction func onReviewsPressed(_ sender: Any) {
        if let reviews = reviewFeed?.reviews, reviews.count > 0 {
            let storyboard = UIStoryboard(name: StoryboardIDs.MainStoryboard, bundle: nil)
            let reviewsVC = storyboard.instantiateViewController(identifier: VCIDs.ReviewsVC) as! ReviewsVC
            reviewsVC.movieId = id
            reviewsVC.reviewFeed = reviewFeed
            reviewsVC.reviews.append(contentsOf: reviews)
            
            present(reviewsVC, animated: true, completion: nil)
        }
    }
    
    
    
}

//MARK: UICollectionViewDelegate implementation
//extension MovieDetailVC: UICollectionViewDelegate {}

//MARK: UICollectionViewDataSource implementation
extension MovieDetailVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return movie?.genres?.count ?? 0
        case 1: return credits?.cast?.count ?? 0
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreCell.id, for: indexPath) as! GenreCell
            if let genres = movie?.genres {
                cell.configure(genre: genres[indexPath.item])
            }
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonCell.id, for: indexPath) as! PersonCell
            if let cast = credits?.cast {
                cell.configure(person: cast[indexPath.item])
            }
            return cell
        default: return UICollectionViewCell()
        }
    }
}

//MARK: UICollectionViewDelegateFlowLayout implementation
extension MovieDetailVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.id, for: indexPath) as! SectionHeader
            
            switch indexPath.section {
            case 0:
                if let genres = movie?.genres, genres.count > 0 {
                    header.configure(section: Section(title: "Genres", fontSize: 17, type: nil), delegate: nil)
                }
            case 1:
                if let cast = credits?.cast, cast.count > 0 {
                    header.configure(section: Section(title: "Cast", fontSize: 17, type: nil), delegate: nil)
                }
            default: break
            }
            return header
        default: return UICollectionReusableView()
        }
    }
}

//extension MovieDetailVC: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let y = 200 - (scrollView.contentOffset.y + 200)
//        let h = max(60, y)
//
//        let rect = CGRect(x: 0, y: 0, width: view.bounds.width, height: h)
//        headerView.frame = rect
//    }
//}
