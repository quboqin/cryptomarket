//
//  SectionHeaderView.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 8/25/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

enum SortSection: String {
    case coin = "Coin"
    case token = "Token"
    case favorite = "Favorite"
    case all
    
    init(section: Int) {
        switch section {
        case 0: self = .coin
        case 1: self = .token
        case 2: self = .favorite
        default: self = .all
        }
    }
}

enum SortKey {
    case name
    case price
    case change
    
    init(key: Int) {
        switch key {
        case 0: self = .name
        case 1: self = .price
        case 2: self = .change
        default: self = .name
        }
    }
}

enum SortOrder {
    case ascend(SortSection, SortKey)
    case descend(SortSection, SortKey)
    case none
}

class SectionHeaderView: UIView {
    @IBOutlet weak var nameContainView: ClickView!
    @IBOutlet weak var priceContainView: ClickView!
    @IBOutlet weak var changeContainView: ClickView!
    var containViews: [ClickView]!
    
    @IBOutlet weak var nameLableInSectionHeader: UILabel!
    
    var viewModel: SectionHeaderViewModel!

    var section: SortSection! {
        didSet {
            nameLableInSectionHeader.text = section.rawValue
            setupBindings(section: section)
        }
    }

    let disposeBag = DisposeBag()
    
    func setupBindings(section: SortSection) {
        self.viewModel = SectionHeaderViewModel(section: section)
        
        containViews = [nameContainView, priceContainView, changeContainView]
        
        for (index, containView) in containViews.enumerated() {
            containView.sortingImage.alpha = 0.1
            containView.rx
                .tapGesture()
                .when(.recognized)
                .bind(to: viewModel.sortOrderSubjects[index])
                .disposed(by: disposeBag)
            
            viewModel.didSelectOrderSubjects[index]
                .subscribe(onNext: { (sortOrder) -> Void in
                    self.containViews[0].sortingImage.alpha = 0.1
                    self.containViews[1].sortingImage.alpha = 0.1
                    self.containViews[2].sortingImage.alpha = 0.1
                    containView.sortingImage.alpha = 1.0
                    
                    UIView.animate(withDuration: 0.5) {
                        if case SortOrder.ascend = sortOrder {
                            containView.sortingImage.transform = CGAffineTransform(rotationAngle: 0)
                        } else {
                            containView.sortingImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                        }
                        
                    }
                })
                .disposed(by: disposeBag)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
