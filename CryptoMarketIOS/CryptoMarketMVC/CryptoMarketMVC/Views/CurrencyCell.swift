//
//  CurrencyCell.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 8/25/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit

class CurrencyCell: UITableViewCell {
    @IBOutlet weak var expandViewHeightConstraint: NSLayoutConstraint!
    private var withExpand: Bool!
    @IBOutlet weak var embeddedView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
//    var expandViewHeightConstraintPriority: Float = 999
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        expandViewHeightConstraint.constant = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setName(_ name: String) {
        nameLabel.text = name
    }
    
    func setWithExpand(_ withExpand: Bool) {
        self.withExpand = withExpand
        
        if(self.withExpand)! {
            //            self.expandViewHeightConstraintPriority = 250
            self.expandViewHeightConstraint.priority = UILayoutPriority(rawValue: 250)
        } else {
            //            self.expandViewHeightConstraintPriority = 999
            self.expandViewHeightConstraint.priority = UILayoutPriority(rawValue: 999)
        }
        
//        UIView.animate(withDuration: 5.0, animations: { [weak self] in
//            self?.layoutIfNeeded()
//        })
        
//        setNeedsUpdateConstraints()
//        or
//        setNeedsLayout()
    }
    
    override func updateConstraints() {
        print("CurrencyCell:In:updateConstraints")
        super.updateConstraints()
        print("CurrencyCell:Out:updateConstraints")
        
//        self.expandViewHeightConstraint.priority = UILayoutPriority(rawValue: self.expandViewHeightConstraintPriority)
    }
    
    override func layoutSubviews() {
        print("CurrencyCell:In:layout subviews")
        super.layoutSubviews()
        print("CurrencyCell:Out:layout subviews")
    }

}
