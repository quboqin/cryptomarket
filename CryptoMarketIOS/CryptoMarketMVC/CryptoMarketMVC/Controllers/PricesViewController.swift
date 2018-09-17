//
//  PricesViewController.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 8/27/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct GlobalViewModel {
    let totalMarketCap: Double
    let totalVolume24H: Double
}

class PricesViewController: CryptoCurrencyListViewController {
    let maxHeaderHeight: CGFloat = 88;
    let minHeaderHeight: CGFloat = 32;
    var previousScrollOffset: CGFloat = 0;
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    var favoritesViewController: FavoritesViewController!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var searchActive: Bool = false
    
    var showCoinOnly = Variable<Bool>(false)

    var coinSectionHeaderView: SectionHeaderView?
    var tokenSectionHeaderView: SectionHeaderView?
    
    var globalData = Variable<GlobalViewModel>(GlobalViewModel(totalMarketCap: 0, totalVolume24H: 0))
    
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
    
    func bindingTableView(_ tickers: Observable<[Ticker]>) {
        let coins = tickers.map { (tickers_) -> [Ticker] in
            return tickers_.filter({ (ticker) -> Bool in
                return !ticker.isToken
            })
        }
        
        let _coins = Observable.combineLatest(coins.asObservable(), self.coinSectionHeaderView!.sortingOrder) {
            (tickers_, sort) -> [Ticker] in
            return self.sortedBykey(tickers: tickers_, key: sort)
        }
        
        let tokens = tickers.map { (tickers_) -> [Ticker] in
            return tickers_.filter({ (ticker) -> Bool in
                return ticker.isToken
            })
        }
        
        let _tokens = Observable.combineLatest(tokens.asObservable(), showCoinOnly.asObservable()) {
            (tickers_, showCoinOnly) -> [Ticker] in
            return tickers_.filter({ (ticker) -> Bool in
                return !showCoinOnly && ticker.isToken
            })
        }
        
        let __tokens = Observable.combineLatest(_tokens.asObservable(), self.coinSectionHeaderView!.sortingOrder) {
            (tickers_, sort) -> [Ticker] in
            return self.sortedBykey(tickers: tickers_, key: sort)
        }
        
        Observable.combineLatest(_coins, __tokens) {
            return ($0, $1)
        }
        .map {
            var sections = [SectionModel<String, Ticker>]()
            if $0.count != 0 {
                sections.append(SectionModel(model: "Coin", items: $0))
            }
            if $1.count != 0 {
                sections.append(SectionModel(model: "Token", items: $1))
            }
        
            return sections
        }
        .bind(to: tableView.rx.items(dataSource: dataSource!))
        .disposed(by: disposeBag)
    }
    
    override func setupBindings() {
        super.setupBindings()
        
        let reload = refreshControl.rx.controlEvent(.valueChanged).asObservable()
        
        reload
            .flatMap { () -> Observable<GlobalResponse> in
                return CoinMarketNetworkManager.shared.getDataFromEndPointRx(.globalData(convert: "USD"),
                                                                                type: GlobalResponse.self)
            }
            .map({ (globalResponse) -> GlobalViewModel in
                return GlobalViewModel(totalMarketCap: globalResponse.data.quotes["USD"]?.totalMarketCap ?? 0, totalVolume24H: globalResponse.data.quotes["USD"]?.totalVolume24H ?? 0)
            })
            .do(onNext: { [weak self] (global) -> Void in
                self?.flipGlobalData()
            })
            .bind(to: globalData)
            .disposed(by: disposeBag)
        
        globalData.asObservable()
            .map { (globalData) -> String in
            return "$" + String(format: "%.1f", globalData.totalMarketCap)
            }
            .bind(to: self.globalLabel.rx.text)
            .disposed(by: disposeBag)


        let coinsRx = PublishSubject<[Coin]>()
        // FIXME: the Variable type has a initial value, if one of the http request return, the combine will be emitted!
//        let coins Rx = Variable<Coin>([])
        
        let tickersRx = PublishSubject<[Ticker]>()

        reload
            .flatMap { () -> Observable<CoinListResponse> in
                return CryptoCompareNetworkManager.shared.getDataFromEndPointRx(.coinlist, type: CoinListResponse.self)
            }
            .map({ [weak self] (coinListResponse) -> [String : Coin] in
                self?.baseImageUrl = coinListResponse.baseImageUrl
                return coinListResponse.data
            })
            .map({
                return [Coin]($0.values)
            })
            .bind(to: coinsRx)
            .disposed(by: disposeBag)
        
        reload
            .flatMap { () -> Observable<TickersResponse> in
                return CoinMarketNetworkManager.shared.getDataFromEndPointRx(.ticker(start: 1, limit: 60, sort: "id", structure: "array", convert: "BTC"), type: TickersResponse.self)
            }
            .map({ (tickersResponse) -> [Ticker] in
                return tickersResponse.data
            })
            .bind(to: tickersRx)
            .disposed(by: disposeBag)

        let _tickers = Observable.combineLatest(tickersRx.asObservable(), coinsRx.asObservable()) { tickers, coins in
            return tickers.map({ (ticker) -> Ticker in
                var _ticker = ticker
                if let coin = coins.first(where: {$0.symbol == ticker.symbol}) {
                    _ticker.fullName = coin.fullName
                    _ticker.imageUrl = coin.imageUrl
                    _ticker.url = coin.url
                    if coin.builtOn != "N/A" {
                        _ticker.isToken = true
                    } else {
                        _ticker.isToken = false
                    }
                } else {
                    _ticker.fullName = ticker.symbol
                }
                return _ticker
            })
        }
        .do(onNext: { [weak self] _ in self?.refreshControl.endRefreshing() })
        
        let searchBehaviorSubject = BehaviorSubject<String>(value: "")
        
        searchBar.rx.text
            .orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .bind(to: searchBehaviorSubject)
            .disposed(by: disposeBag)
        
        let __tickers = Observable.combineLatest(_tickers.asObservable(), searchBehaviorSubject.asObserver()) {
            (tickers, search) -> [Ticker] in
            let lowcasedSearch = search.lowercased()
            return tickers.filter {
                if lowcasedSearch == "" {
                    return true
                }
                return $0.fullName.lowercased().range(of: lowcasedSearch) != nil
            }
        }

        bindingTableView(__tickers)
        
        refreshControl.beginRefreshing()
        refreshControl.sendActions(for: .valueChanged)
    }
    
    override func setupUI() {
        super.setupUI()
        
        tableView.insertSubview(refreshControl, at: 0)
        
        cellIdentifier = "CurrencyCell1"
        
        self.coinSectionHeaderView = UINib(nibName: "SectionHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? SectionHeaderView
        self.coinSectionHeaderView?.section = .coin
        self.tokenSectionHeaderView = UINib(nibName: "SectionHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? SectionHeaderView
        self.tokenSectionHeaderView?.section = .token
        
        let navigationViewController = self.tabBarController?.viewControllers![1] as! UINavigationController
        self.favoritesViewController = navigationViewController.topViewController as? FavoritesViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        // FIXME: You need to call [self.view layoutIfNeeded] to fix it in iOS 10 to make refreshControl refresh when the view controller is loading.
        self.view.layoutIfNeeded()
        
        setupBindings()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        segue.destination.transitioningDelegate = self
        
        if let navigationController = segue.destination as? SettingsNavigationController,
            let settingsViewController = navigationController.viewControllers.first as? SettingsViewController {
    
            settingsViewController.didSelectShowCoinOnly
                .bind(to: showCoinOnly)
                .disposed(by: disposeBag)
            
            // FIXED: How to save the status
            settingsViewController._selectShowCoinOnly.onNext(showCoinOnly.value)

            if let favoriteViewController = self.favoritesViewController {
                settingsViewController.didSelectRemoveMyFavorites
                    .bind(to: favoriteViewController._selectRemoveMyFavorites)
                    .disposed(by: disposeBag)
            }
            
            if let expandViewController = self.expandViewController {
                settingsViewController.didSwitchKlineSource
                    .bind(to: expandViewController._switchKlineSource)
                    .disposed(by: disposeBag)
                
                settingsViewController._switchKlineSource.onNext(KLineSource.shared.dataSource)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PricesViewController {    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let favoriteRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Favorite", handler:{ [weak self] action, indexpath in
            
            guard let ticker = self?.dataSource?[indexPath] else {
                return
            }
            
            self?.favoritesViewController.baseImageUrl = self?.baseImageUrl
            self?.favoritesViewController.addTicker(ticker)
        })
        
        return [favoriteRowAction]
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 && self.coinSectionHeaderView == nil || section == 1 && self.tokenSectionHeaderView == nil {
            if let headerView = super.tableView(tableView, viewForHeaderInSection: section) as? SectionHeaderView {
                if section == 0 {
                    headerView.section = SortSection.coin
                    self.coinSectionHeaderView = headerView
                } else {
                    headerView.section = SortSection.token
                    self.tokenSectionHeaderView = headerView
                }
                return headerView
            }
            return self.coinSectionHeaderView
        } else if section == 0 {
            return self.coinSectionHeaderView
        } else {
            return self.tokenSectionHeaderView
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
