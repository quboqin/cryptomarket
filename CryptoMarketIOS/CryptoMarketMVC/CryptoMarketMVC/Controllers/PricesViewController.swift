//
//  PricesViewController.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 8/27/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit

class PricesViewController: CryptoCurrencyListViewController {
    let maxHeaderHeight: CGFloat = 88;
    let minHeaderHeight: CGFloat = 32;
    var previousScrollOffset: CGFloat = 0;
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    var favoritesViewController: FavoritesViewController!
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredTickers = [String]()
    var searchActive: Bool = false
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var globalLabel: UILabel!
    
    func flipGlobalData() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let transformAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        transformAnimation.fromValue = CATransform3DMakeRotation(0, 1, 0, 0)
        transformAnimation.toValue = CATransform3DMakeRotation(CGFloat(Double.pi), 1, 0, 0)
        transformAnimation.duration = 2
        transformAnimation.autoreverses = true
        transformAnimation.repeatCount = .infinity
        
        CATransaction.setCompletionBlock({
            self.globalLabel.layer.transform = CATransform3DMakeRotation(0, 1, 0, 0)
        })
        
        self.globalLabel.layer.add(transformAnimation, forKey: #keyPath(CALayer.transform))
        
        CATransaction.commit()
    }

    @objc
    fileprivate func reloadData() {
        refreshControl.beginRefreshing()
        
        tickers = ["Bitcoin", "Ether", "XRP", "EOS", "Litecoin", "IOTA"]
        tableView.reloadData()
        
        refreshControl.endRefreshing()
    }
    
    private func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.insertSubview(refreshControl, at: 0)
        
        refreshControl.addTarget(self, action: #selector(PricesViewController.reloadData), for: .valueChanged)
        
        cellIdentifier = "CurrencyCell1"

        flipGlobalData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let _tickers = searchActive && filteredTickers.count > 0 ? filteredTickers : tickers
        
        return _tickers.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _tickers = searchActive && filteredTickers.count > 0 ? filteredTickers : tickers
        
        return _tableView(tableView, cellForRowAt: indexPath, with: _tickers[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        segue.destination.transitioningDelegate = self
        
        if let navigationController = segue.destination as? SettingsNavigationController,
            let settingsViewController = navigationController.viewControllers.first as? SettingsViewController {

            settingsViewController.delegate = self
        }
    }
}

extension PricesViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTransitionController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransitionController()
    }
}

extension PricesViewController {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let favoriteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Favorite", handler:{ [weak self] action, indexpath in
            let _tickers = (self?.searchActive)! && (self?.filteredTickers.count)! > 0 ? self?.filteredTickers : self?.tickers
            
            let navigationViewController = self?.tabBarController?.viewControllers![1] as! UINavigationController
            self?.favoritesViewController = navigationViewController.topViewController as! FavoritesViewController
            
            self?.favoritesViewController.addTicker(_tickers![indexPath.row])
        })
        
        return [favoriteRowAction]
    }
}

extension PricesViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        if canAnimateHeader(scrollView) {
            
            // Calculate new header height
            var newHeight = self.headerHeightConstraint.constant
            if isScrollingDown {
                newHeight = max(self.minHeaderHeight, self.headerHeightConstraint.constant - abs(scrollDiff))
            } else if isScrollingUp {
                newHeight = min(self.maxHeaderHeight, self.headerHeightConstraint.constant + abs(scrollDiff))
            }
            
            // Header needs to animate
            if newHeight != self.headerHeightConstraint.constant {
                self.headerHeightConstraint.constant = newHeight
                self.updateHeader()
            }
            
            self.previousScrollOffset = scrollView.contentOffset.y
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidStopScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidStopScrolling()
        }
    }
    
    func scrollViewDidStopScrolling() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let midPoint = self.minHeaderHeight + (range / 2)
        
        if self.headerHeightConstraint.constant > midPoint {
            self.expandHeader()
        } else {
            self.collapseHeader()
        }
    }
    
    func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        // Calculate the size of the scrollView when header is collapsed
        let scrollViewMaxHeight = scrollView.frame.height + self.headerHeightConstraint.constant - minHeaderHeight
        
        // Make sure that when header is collapsed, there is still room to scroll
        return scrollView.contentSize.height > scrollViewMaxHeight
    }
    
    func collapseHeader() {
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.minHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func expandHeader() {
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.maxHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func updateHeader() {
        
    }
}

extension PricesViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let lowercasedSearchText = searchText.lowercased()
        filteredTickers = tickers.filter({
            return $0.lowercased().range(of: lowercasedSearchText) != nil
        })
        
        if(filteredTickers.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        
        self.tableView.reloadData()
    }
    
}

extension PricesViewController: SettingsViewControllerDelegate {
    func settingsViewControllerDidCancel(_ viewController: SettingsViewController) {
        print("Click Cancel button @Prices")
    }
    
    func settingsViewController(_ viewController: SettingsViewController, didSelectTokenOnly isOnlyToken: Bool) {
        print("Select ShowTokenOnly switch \(isOnlyToken) @Prices")
    }
    
    func settingsViewController(_ viewController: SettingsViewController, didSaveMyFavorites isSaveMyFavorites: Bool) {
        print("Select SaveMyFavorites switch \(isSaveMyFavorites) @Prices")
    }
    
    func settingsViewController(_ viewController: SettingsViewController, didSelectDataSource dataSource: DataSource) {
        print("Select kLine Datasource \(dataSource) @Prices")
    }
}
