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

    var coinSectionHeaderView: SectionHeaderView?
    var tokenSectionHeaderView: SectionHeaderView?
    
    private let viewModel = PriceViewModel()
    
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
    
    override func setupBindings() {
        super.setupBindings()
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.reload)
            .disposed(by: disposeBag)
        
        searchBar.rx.text
            .orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .bind(to: viewModel.setSearchKeyword)
            .disposed(by: disposeBag)
        
        self.coinSectionHeaderView?.sortingOrder
            .bind(to: viewModel.setCoinSortOrder)
            .disposed(by: disposeBag)
        
        self.tokenSectionHeaderView?.sortingOrder
            .bind(to: viewModel.setTokenSortOrder)
            .disposed(by: disposeBag)
        
        viewModel.totalVolume24H
            .do(onNext: { [weak self] (global) -> Void in
                self?.flipGlobalData()
            })
            .bind(to: self.globalLabel.rx.text)
            .disposed(by: disposeBag)
    
        viewModel.baseImageUrl
            .bind(to: GlobalStatus.shared.baseImageUrl)
            .disposed(by: disposeBag)
        
        viewModel.sections
            .do(onNext: { [weak self] _ in self?.refreshControl.endRefreshing() })
            .bind(to: tableView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshControl.beginRefreshing()
        refreshControl.sendActions(for: .valueChanged)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        segue.destination.transitioningDelegate = self
        
        if let navigationController = segue.destination as? SettingsNavigationController,
            let settingsViewController = navigationController.viewControllers.first as? SettingsViewController {
    
            settingsViewController.viewModel.didSelectShowCoinOnly
                .bind(to: viewModel.showCoinOnly)
                .disposed(by: disposeBag)
            
            settingsViewController.viewModel.didSelectDataSource.debug()
                .bind(to: GlobalStatus.shared.klineDataSource)
                .disposed(by: disposeBag)
            
            // FIXED: How to save the status
            settingsViewController.viewModel.selectShowCoinOnly.onNext(viewModel.showCoinOnly.value)
            settingsViewController.viewModel.selectDataSource.onNext(GlobalStatus.shared.klineDataSource.value)

            if let favoriteViewController = self.favoritesViewController {
                settingsViewController.viewModel.didSelectRemoveMyFavorites
                    .bind(to: favoriteViewController.viewModel.deleteFavoriteList)
                    .disposed(by: disposeBag)
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
        
            self?.favoritesViewController.viewModel.addTicker.onNext(ticker)
        })
        
        return [favoriteRowAction]
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
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
