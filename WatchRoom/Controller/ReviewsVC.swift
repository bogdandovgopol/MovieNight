//
//  ReviewsVC.swift
//  WatchRoom
//
//  Created by Bogdan on 5/9/20.
//

import UIKit
import FirebaseCrashlytics

class ReviewsVC: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Variables
    var movieId: Int!
    var reviewFeed: ReviewFeed!
    var reviews = [Review]()
    var reviewsPage = 1
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        configureCollectionView()
        
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
        
        collectionView.register(ReviewCell.nib, forCellWithReuseIdentifier: ReviewCell.id)
        collectionView.register(SectionHeader.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.id)
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionNumber, _) -> NSCollectionLayoutSection? in
            switch sectionNumber {
            case 0:
                return self.reviewsSection()
            default:
                return self.reviewsSection()
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        layout.configuration = config
        return layout
    }
    
    //MARK: CollectionViewLayout sections
    
    /// - Tag: Reviews section
    func reviewsSection() -> NSCollectionLayoutSection {
 
        //define item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(10))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //configurate item
//        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 16)
        
        //define group
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        
        //define section
        let section = NSCollectionLayoutSection(group: group)
        //configure section
        section.contentInsets.leading = 16
        
        //configure header
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(45))
        section.boundarySupplementaryItems = [
            .init(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        ]
        
        
        return section
    }
    
    //MARK: Get reviews
    func loadMovieReviews(id: Int, page: Int, section: Int) {
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
                    if let reviews = feed.reviews, reviews.count > 0 {
                        if page > 1 {
                            var indexPaths = [IndexPath]()
                            for item in 0..<reviews.count {
                                let indexPath = IndexPath(row: item + self.reviews.count, section: section)
                                indexPaths.append(indexPath)
                            }
                            self.collectionView.performBatchUpdates({
                                self.reviews.append(contentsOf: reviews)
                                self.collectionView.insertItems(at: indexPaths)
                                
                            }, completion: nil)
                            
                        } else {
                            self.reviews.append(contentsOf: reviews)
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
}


//MARK: UICollectionViewDelegate implementation
extension ReviewsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == reviews.count - 2 {
            if reviewsPage < reviewFeed.totalPages ?? 0 {
                reviewsPage += 1
                loadMovieReviews(id: movieId, page: reviewsPage, section: 0)
            }
        }
    }
}

//MARK: UICollectionViewDataSource implementation
extension ReviewsVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return reviews.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCell.id, for: indexPath) as! ReviewCell
            cell.configure(review: reviews[indexPath.item])
            return cell
        default: return UICollectionViewCell()
        }
    }
}

//MARK: UICollectionViewDelegateFlowLayout implementation
extension ReviewsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.id, for: indexPath) as! SectionHeader
            
            switch indexPath.section {
            case 0:
                header.configure(section: Section(title: "Reviews", fontSize: nil, type: nil), delegate: nil)
            default: break
            }
            return header
        default: return UICollectionReusableView()
        }
    }
}
