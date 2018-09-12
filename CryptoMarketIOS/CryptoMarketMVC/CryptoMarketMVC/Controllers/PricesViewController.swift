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
    var filteredTickers = [Ticker]()
    var searchActive: Bool = false
    
    var showCoinOnly = false
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @objc
    fileprivate func reloadData() {
        refreshControl.beginRefreshing()
        
        let cryptoCompareNetworkManager = CryptoCompareNetworkManager.shared
        let coinMarketNetworkManager = CoinMarketNetworkManager.shared
        
        _ = cryptoCompareNetworkManager.getDataFromEndPoint(.coinlist, type: CoinListResponse.self) { [weak self]
            (data, error) in
            if error != nil {
                self?.refreshControl.endRefreshing()
                return
            }
    
            if let coinListResponse = data as? CoinListResponse {
                self?.baseImageUrl = coinListResponse.baseImageUrl
                let coins = [Coin](coinListResponse.data.values)
                
                _ = coinMarketNetworkManager.getDataFromEndPoint(.ticker(start: 1, limit: 60, sort: "id", structure: "array", convert: "BTC"), type: TickersResponse.self, networkManagerCompletion: { [weak self]
                    (data, error) in
                    if error != nil {
                        self?.refreshControl.endRefreshing()
                        return
                    }
                    
                    if let tickersResponse = data as? TickersResponse {
                        self?.tickers = tickersResponse.data
                        
                        for (index, ticker) in (self?.tickers)!.enumerated() {
                            if let coin = coins.first(where: {$0.symbol == ticker.symbol}) {
                                self?.tickers[index].fullName = coin.fullName
                                self?.tickers[index].imageUrl = coin.imageUrl
                                self?.tickers[index].url = coin.url
                                if coin.builtOn != "N/A" {
                                    self?.tickers[index].isToken = true
                                } else {
                                    self?.tickers[index].isToken = false
                                }
                            } else {
                                self?.tickers[index].fullName = (self?.tickers[index].symbol)!
                            }
                        }
                        self?.tableView.reloadData()
                    }
                    self?.refreshControl.endRefreshing()
                })
            }
            self?.refreshControl.endRefreshing()
        }
        
        _ = coinMarketNetworkManager.getDataFromEndPoint(.globalData(convert: "USD"), type: GlobalResponse.self) { [weak self]
            (data, error) in
            if error != nil {
                return
            }
            
            if let globalResponse = data as? GlobalResponse {
                let totalVolume24H = globalResponse.data.quotes["USD"]?.totalVolume24H
                self?.globalLabel.text = "$" + String(format: "%.1f", totalVolume24H!)
                self?.flipGlobalData()
            }
        }
    }
    
    private func setupUI() {
        tableView.tableFooterView = UIView()
        
        tableView.insertSubview(refreshControl, at: 0)
        refreshControl.addTarget(self, action: #selector(PricesViewController.reloadData), for: .valueChanged)
        
        cellIdentifier = "CurrencyCell1"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        // FIXME: You need to call [self.view layoutIfNeeded] to fix it in iOS 10.
        self.view.layoutIfNeeded()
        reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let _tickers = searchActive && filteredTickers.count > 0 ? filteredTickers : tickers
        
        if _tickers.count == 0 {
            return 0
        }
        return showCoinOnly ? 1 : 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let _tickers = searchActive && filteredTickers.count > 0 ? filteredTickers : tickers
        
        return showCoinOnly ? _tickers.filter({ !$0.isToken }).count
            : (section == 0 ? _tickers.filter({ !$0.isToken }).count
                : _tickers.filter({ $0.isToken }).count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _tickers = searchActive && filteredTickers.count > 0 ? filteredTickers : tickers
        
        let ticker = showCoinOnly ? _tickers.filter({ !$0.isToken })[indexPath.row]
            : (indexPath.section == 0 ? _tickers.filter({ !$0.isToken })[indexPath.row]
                : _tickers.filter({ $0.isToken })[indexPath.row])
        
        return _tableView(tableView, cellForRowAt: indexPath, with: ticker)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        segue.destination.transitioningDelegate = self
        
        if let navigationController = segue.destination as? SettingsNavigationController,
            let settingsViewController = navigationController.viewControllers.first as? SettingsViewController {
            
            settingsViewController.showCoinOnly = showCoinOnly
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
            
            let ticker = (self?.showCoinOnly)! ? _tickers?.filter({ !$0.isToken })[indexPath.row]
                : (indexPath.section == 0 ? _tickers?.filter({ !$0.isToken })[indexPath.row]
                    : _tickers?.filter({ $0.isToken })[indexPath.row])
            
            let navigationViewController = self?.tabBarController?.viewControllers![1] as! UINavigationController
            self?.favoritesViewController = navigationViewController.topViewController as! FavoritesViewController
            
            self?.favoritesViewController.baseImageUrl = self?.baseImageUrl
            self?.favoritesViewController.addTicker(ticker!)
        })
        
        return [favoriteRowAction]
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = super.tableView(tableView, viewForHeaderInSection: section) as? SectionHeaderView {
            headerView.setName(section == 0 ?  "Coin" : "Token")
            return headerView
        }
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let _tickers = self.searchActive && self.filteredTickers.count > 0 ? self.filteredTickers : self.tickers
        
        if showCoinOnly && _tickers.filter({ !$0.isToken }).count == 0 {
            return 0
        }
        
        return super.tableView(tableView, heightForHeaderInSection: section)
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
            return $0.fullName.lowercased().range(of: lowercasedSearchText) != nil
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
        Log.v("Click Cancel button")
    }
    
    func settingsViewController(_ viewController: SettingsViewController, didSelectTokenOnly isOnlyCoin: Bool) {
        showCoinOnly = isOnlyCoin
        self.tableView.reloadData()
        Log.v("Select ShowTokenOnly switch \(isOnlyCoin)")
    }
    
    func settingsViewController(_ viewController: SettingsViewController, didSaveMyFavorites isSaveMyFavorites: Bool) {
        Log.v("Select SaveMyFavorites switch \(isSaveMyFavorites)")
    }
    
    func settingsViewController(_ viewController: SettingsViewController, didSelectDataSource dataSource: DataSource) {
        Log.v("Select kLine Datasource \(dataSource)")
    }
}
