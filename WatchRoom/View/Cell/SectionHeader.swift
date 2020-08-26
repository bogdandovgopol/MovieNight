//
//  SectionHeader.swift
//  WatchRoom
//
//  Created by Bogdan on 21/8/20.
//

import UIKit

protocol SectionHeaderDelegate: class {
    func seeAll(section: Section)
}

class SectionHeader: UICollectionReusableView {
    
    //MARK: Outlets
    @IBOutlet weak var titleTxt: UILabel!
    @IBOutlet weak var actionBtn: UIButton!
    
    // MARK: Delegates
    weak var delegate: SectionHeaderDelegate?
    
    // MARK: Variables
    private var section: Section!
    static let id = "SectionHeader"
    static let nib = UINib(nibName: id, bundle: nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func configure(section: Section, delegate: SectionHeaderDelegate? = nil) {
        if delegate != nil {
            self.delegate = delegate
            actionBtn.isHidden = false
        }
        
        self.section = section
        titleTxt.text = section.title
    }
    
    @IBAction func onSeeAllPressed(_ sender: Any) {
        delegate?.seeAll(section: section)
    }
}
