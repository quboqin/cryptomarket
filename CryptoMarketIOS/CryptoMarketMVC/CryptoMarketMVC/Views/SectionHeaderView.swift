//
//  SectionHeaderView.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 8/25/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit

enum Sorting {
    case name
    case nameDesc
    case price
    case priceDesc
    case change
    case changeDesc
    case none
    
    init(index: Int) {
        switch index {
        case 0: self = .name
        case 1: self = .nameDesc
        case 2: self = .price
        case 3: self = .priceDesc
        case 4: self = .change
        case 5: self = .changeDesc
        default:
            self = .none
        }
    }
}

enum SortOrder {
    case ascend
    case descend
}

enum Section {
    case coin
    case token
    case favorite
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

class SectionHeaderView: UIView {
    @IBOutlet weak var nameContainView: UIView!
    @IBOutlet weak var priceContainView: UIView!
    @IBOutlet weak var changeContainView: UIView!
    
    @IBOutlet weak var nameSortingImage: UIImageView!
    @IBOutlet weak var priceSortingImage: UIImageView!
    @IBOutlet weak var changeSortingImage: UIImageView!
    
    var sortOrders = [SortOrder.descend, SortOrder.descend, SortOrder.descend]
    var sortingImageViews: [UIImageView]!
    
    weak var delegate: SectionHeaderViewDelegate?
    
    @IBOutlet weak var nameLableInSectionHeader: UILabel!
    
    func setName(_ name: String) {
        nameLableInSectionHeader.text = name
    }
    
    @objc private func tapLabel(sender: UITapGestureRecognizer) {
        if let whichOne = sender.view?.tag {
            UIView.animate(withDuration: 0.5) {
                if self.sortOrders[whichOne] == SortOrder.ascend {
                    self.sortOrders[whichOne] = SortOrder.descend
                    self.sortingImageViews[whichOne].transform = CGAffineTransform(rotationAngle: 0)
                } else {
                    self.sortOrders[whichOne] = SortOrder.ascend
                    self.sortingImageViews[whichOne].transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                }
                
                self.sortingImageViews[0].alpha = 0.5
                self.sortingImageViews[1].alpha = 0.5
                self.sortingImageViews[2].alpha = 0.5
                self.sortingImageViews[whichOne].alpha = 1.0
            }
            delegate?.sectionHeaderView(self, tap: whichOne)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        sortingImageViews = [nameSortingImage, priceSortingImage, changeSortingImage]

        let tapGestureName = UITapGestureRecognizer(target: self, action: #selector(tapLabel(sender:)))
        nameContainView.addGestureRecognizer(tapGestureName)
        let tapGesturePrice = UITapGestureRecognizer(target: self, action: #selector(tapLabel(sender:)))
        priceContainView.addGestureRecognizer(tapGesturePrice)
        let tapGestureChange = UITapGestureRecognizer(target: self, action: #selector(tapLabel(sender:)))
        changeContainView.addGestureRecognizer(tapGestureChange)
    }

}

protocol SectionHeaderViewDelegate: class {
    func sectionHeaderView(_ sectionHeaderView: SectionHeaderView, tap which: Int)
}
