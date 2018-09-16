//
//  CryptoCurrencyListViewController.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 8/25/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit
import SafariServices
import RxSwift
import RxDataSources

class CryptoCurrencyListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var expandedIndexPaths: Set<IndexPath> = []
    var expandViewController: ExpandViewController?
    
    var tickers = [Ticker]()
    var baseImageUrl: String!
    
    var sectionHeaderView: SectionHeaderView?
    var cellIdentifier = "CurrencyCell2"
    
    var currentUrlString: String?
    
    var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, Ticker>>?
    let disposeBag = DisposeBag()
    
    @IBAction func presentSafariViewController(_ sender: Any) {
        guard let urlString = currentUrlString,
              let url = URL(string: urlString) else {
            return
        }
        
        let vc = DetailViewController(url: url)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func sortedBykey(tickers: [Ticker], key: SortOrder) -> [Ticker] {
        if case SortOrder.ascend(_, let _key) = key {
            switch _key {
            case .name:
                return tickers.sorted(by: {
                    $0.fullName < $1.fullName
                })
            case .price:
                return tickers.sorted(by: {
                    $0.quotes["USD"]!.price < $1.quotes["USD"]!.price
                })
            case .change:
                return tickers.sorted(by: {
                    $0.quotes["USD"]!.percentChange24h < $1.quotes["USD"]!.percentChange24h
                })
            }
        }
        if case SortOrder.descend(_, let _key) = key {
            switch _key {
            case .name:
                return tickers.sorted(by: {
                    $0.fullName > $1.fullName
                })
            case .price:
                return tickers.sorted(by: {
                    $0.quotes["USD"]!.price > $1.quotes["USD"]!.price
                })
            case .change:
                return tickers.sorted(by: {
                    $0.quotes["USD"]!.percentChange24h > $1.quotes["USD"]!.percentChange24h
                })
            }
        }
        return tickers
    }
    
    func setupBinding() {
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Ticker>>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! CurrencyCell
                cell.selectionStyle = .none
                cell.setCoinImage(item.imageUrl, with: (self.baseImageUrl)!)
                cell.setName(item.fullName)
                cell.setPrice((item.quotes["USD"]?.price)!)
                cell.setChange((item.quotes["USD"]?.percentChange24h)!)
                cell.setVolume24h((item.quotes["USD"]?.volume24h)!)
                
                self.currentUrlString = (self.baseImageUrl)! + item.url
                return cell
        })
        
        dataSource?.canEditRowAtIndexPath = { dataSource, indexPath in
            return true
        }
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CryptoCurrencyListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CurrencyCell
        return cell
    }
    
    func _tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, with ticker: Ticker) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CurrencyCell
        
        cell.selectionStyle = .none
        cell.setCoinImage(ticker.imageUrl, with: baseImageUrl)
        cell.setName(ticker.fullName)
        cell.setPrice((ticker.quotes["USD"]?.price)!)
        cell.setChange((ticker.quotes["USD"]?.percentChange24h)!)
        cell.setVolume24h((ticker.quotes["USD"]?.volume24h)!)
        
        self.currentUrlString = baseImageUrl + ticker.url
        
        cell.setWithExpand(self.expandedIndexPaths.contains(indexPath))
        
        if self.expandedIndexPaths.contains(indexPath) {
            self.expandViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExpandViewController") as? ExpandViewController
            if let expandViewController = self.expandViewController {
                self.addChildViewController(expandViewController)
                cell.embeddedView.addSubview(expandViewController.view)

                expandViewController.view.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate([
                    expandViewController.view.leadingAnchor.constraint(equalTo: cell.embeddedView.leadingAnchor),
                    expandViewController.view.trailingAnchor.constraint(equalTo: cell.embeddedView.trailingAnchor),
                    expandViewController.view.topAnchor.constraint(equalTo: cell.embeddedView.topAnchor),
                    expandViewController.view.bottomAnchor.constraint(equalTo: cell.embeddedView.bottomAnchor)
                    ])

                expandViewController.didMove(toParentViewController: self)
                
                expandViewController.symbol = ticker.symbol
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !self.expandedIndexPaths.contains(indexPath as IndexPath)
    }
}

extension CryptoCurrencyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.sectionHeaderView == nil {
            self.sectionHeaderView = UINib(nibName: "SectionHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? SectionHeaderView
        }
        if let headerView = self.sectionHeaderView {
            headerView.backgroundColor = .groupTableViewBackground
            self.sectionHeaderView = nil
            return headerView
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var indexPaths = [IndexPath]()
        
        if(self.expandedIndexPaths.contains(indexPath)) {
            self.expandedIndexPaths.remove(indexPath)
            
            expandViewController?.willMove(toParentViewController: self)
            expandViewController?.view.removeFromSuperview()
            expandViewController?.removeFromParentViewController()
            self.expandViewController = nil
            
        } else {
            if self.expandedIndexPaths.count > 0 {
                indexPaths.append(self.expandedIndexPaths.removeFirst())
            }
            self.expandedIndexPaths.insert(indexPath)
        }
        indexPaths.append(indexPath)
        
        tableView.reloadRows(at: indexPaths, with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}

extension CryptoCurrencyListViewController: SFSafariViewControllerDelegate {
    private func safariViewControllerDidFinish(_ controller: DetailViewController) {
        dismiss(animated: true)
    }
}
