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
    case nameDesc
    case price
    case priceDesc
    case change
    case changeDesc
    
    init?(index: Int) {
        switch index {
        case 0: self = .name
        case 1: self = .nameDesc
        case 2: self = .price
        case 3: self = .priceDesc
        case 4: self = .change
        case 5: self = .changeDesc
        default:
            self = .name
        }
    }
}

enum WhichHeader {
    case coin
    case token
    case favorite
}

class SectionHeaderView: UIView {
    @IBOutlet weak var nameContainView: UIView!
    @IBOutlet weak var priceContainView: UIView!
    @IBOutlet weak var changeContainView: UIView!
    
    weak var delegate: SectionHeaderViewDelegate?
    
    @IBOutlet weak var nameLableInSectionHeader: UILabel!
    
    func setName(_ name: String) {
        nameLableInSectionHeader.text = name
    }
    
    @objc private func tapLabel(sender: UITapGestureRecognizer) {
        let whichOne = sender.view?.tag
        delegate?.sectionHeaderView(self, tap: whichOne!)
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
    func sectionHeaderView(_ sectionHeaderView: SectionHeaderView, tap sortBy: Int)
}
