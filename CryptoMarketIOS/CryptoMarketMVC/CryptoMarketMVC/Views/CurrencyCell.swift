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
    @IBOutlet weak var coinImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    
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
    
    fileprivate func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    fileprivate func downloadImage(url: URL) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                self.coinImageView.image = UIImage(data: data)
            }
        }
    }
    
    func  setCoinImage(_ name: String, with baseImageUrl: String) {
        if name.isEmpty {
            coinImageView.image = UIImage(named: "btc.png")
            return
        }
        if let url = URL(string: baseImageUrl + name) {
            coinImageView.image = nil
            downloadImage(url: url)
        }
    }
    
    func setName(_ name: String) {
        nameLabel.text = name
    }
    
    func setPrice(_ price: Double) {
        priceLabel.text = "$" + String(format: "%.2f", price)
    }
    
    func setChange(_ change: Double) {
        changeLabel.text = String(format: "%0.2f", change) + "%"
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
        super.updateConstraints()
        
//        self.expandViewHeightConstraint.priority = UILayoutPriority(rawValue: self.expandViewHeightConstraintPriority)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
