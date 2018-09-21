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

    var section: SortSection! {
        didSet {
            nameLableInSectionHeader.text = section.rawValue
        }
    }
    var sortingOrder: Observable<SortOrder>!
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containViews = [nameContainView, priceContainView, changeContainView]
        var sortOrderSubjects = [BehaviorSubject<SortOrder>(value: SortOrder.none), BehaviorSubject<SortOrder>(value: SortOrder.none), BehaviorSubject<SortOrder>(value: SortOrder.none)]
        
        for (index, containView) in containViews.enumerated() {
            let sortKey = SortKey(key: index)
            containView.sortingImage.alpha = 0.1
            containView.rx
                .tapGesture()
                .when(.recognized)
                .map {_ in
                    return sortOrderSubjects[index]
                }
                .scan(SortOrder.none) { lastValue, _ in
                    if case SortOrder.ascend(let _section, let _key) = lastValue {
                        return SortOrder.descend(_section, _key)
                    }
                    if case SortOrder.descend(let _section, let _key) = lastValue {
                        return SortOrder.ascend(_section, _key)
                    }
                    return SortOrder.ascend(self.section, sortKey)
                }
                .do(onNext: { (sortOrder) -> Void in
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
                }).bind(to: sortOrderSubjects[index])
                .disposed(by: disposeBag)
        }
        sortingOrder = Observable.from(sortOrderSubjects).merge()
    }
}
