//
//  SectionHeaderView.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 8/25/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit

enum SortBy {
    case name
    case price
    case change
    
    init?(index: Int) {
        switch index {
        case 0: self = .name
        case 1: self = .price
        case 2: self = .change
        default:
            self = .name
        }
    }
}

class SectionHeaderView: UIView {
    @IBOutlet weak var nameContainView: UIView!
    @IBOutlet weak var priceContainView: UIView!
    @IBOutlet weak var changeContainView: UIView!
    
    weak var delegate: SectionHeaderViewDelegate?
    
    @objc private func tapLabel(sender: UITapGestureRecognizer) {
        let whichOne = sender.view?.tag
        delegate?.sectionHeaderView(self, tap: SortBy(index: whichOne!)!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        let tapGestureName = UITapGestureRecognizer(target: self, action: #selector(tapLabel(sender:)))
        nameContainView.addGestureRecognizer(tapGestureName)
        let tapGesturePrice = UITapGestureRecognizer(target: self, action: #selector(tapLabel(sender:)))
        priceContainView.addGestureRecognizer(tapGesturePrice)
        let tapGestureChange = UITapGestureRecognizer(target: self, action: #selector(tapLabel(sender:)))
        changeContainView.addGestureRecognizer(tapGestureChange)
    }

}

protocol SectionHeaderViewDelegate: class {
    func sectionHeaderView(_ sectionHeaderView: SectionHeaderView, tap sortBy: SortBy)
}
