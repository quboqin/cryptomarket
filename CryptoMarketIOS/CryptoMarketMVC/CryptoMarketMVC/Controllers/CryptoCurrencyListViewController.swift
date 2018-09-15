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

class CryptoCurrencyListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var expandedIndexPaths: Set<IndexPath> = []
    var expandViewController: ExpandViewController?
    
    var tickers = [Ticker]()
    var baseImageUrl: String!
    
    var sectionSortedArray = [Sorting.none, Sorting.none, Sorting.none]
    
    var sectionHeaderView: SectionHeaderView?
    var cellIdentifier = "CurrencyCell2"
    
    var currentUrlString: String?
    
    func setupBinding() {
    }
    
    @IBAction func presentSafariViewController(_ sender: Any) {
        guard let urlString = currentUrlString,
              let url = URL(string: urlString) else {
            return
        }
        
        let vc = DetailViewController(url: url)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
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
            headerView.delegate = self
            headerView.backgroundColor = .groupTableViewBackground
            self.sectionHeaderView = nil
            return headerView
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
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

extension CryptoCurrencyListViewController: SectionHeaderViewDelegate {
    func sectionHeaderView(_ sectionHeaderView: SectionHeaderView, tap whichCol: Int) {
        var _sorted = sectionSortedArray[sectionHeaderView.tag]

        switch whichCol {
        case 0:
            if _sorted == .nameDesc || _sorted == .none {
                _sorted = .name
            } else {
                _sorted = .nameDesc
            }
        case 1:
            if _sorted == .priceDesc {
                _sorted = .price
            } else {
                _sorted = .priceDesc
            }
        case 2:
            if _sorted == .changeDesc {
                _sorted = .change
            } else {
                _sorted = .changeDesc
            }
        default:
            return
        }
        
        sectionSortedArray[sectionHeaderView.tag] = _sorted
    
        var sectionToReload = sectionHeaderView.tag
        if sectionToReload == Section.favorite.hashValue {
            sectionToReload = 0
        }
        let indexSet: IndexSet = [sectionToReload]
        self.tableView.reloadSections(indexSet, with: .automatic)

        Log.d("Tap \(whichCol)")
    }
}

extension Array where Element == Ticker {
    func filter(BySearch searchText: String?) -> [Ticker] {
        var filterTickers = [Ticker]()
        if let lowcasedSearchText = searchText?.lowercased() {
            filterTickers = self.filter { $0.fullName.lowercased().range(of: lowcasedSearchText) != nil }
        }
        if filterTickers.count == 0 {
            filterTickers = self
        }
        return filterTickers
    }
    
    func milter(filterBy searchText: String?, separatedBy section: Section, sortedBy condition: Sorting) -> [Ticker] {
        var filterTickers = [Ticker]()
        filterTickers = filter(BySearch: searchText)
        
        filterTickers = filterTickers.filter {
            switch section {
            case .coin:
                return !$0.isToken
            case .token:
                return $0.isToken
            default:
                return true
            }
        }
        
        if condition == .none {
            return filterTickers
        }
        filterTickers = filterTickers.sorted {
            switch condition {
            case .name:
                return $0.fullName < $1.fullName
            case .nameDesc:
                return $0.fullName > $1.fullName
            case .change:
                return $0.quotes["USD"]!.percentChange24h < $1.quotes["USD"]!.percentChange24h
            case .changeDesc:
                return $0.quotes["USD"]!.percentChange24h > $1.quotes["USD"]!.percentChange24h
            case .price:
                return $0.quotes["USD"]!.price < $1.quotes["USD"]!.price
            case .priceDesc:
                return $0.quotes["USD"]!.price > $1.quotes["USD"]!.price
            default:
                return $0.fullName < $1.fullName
            }
        }
        
        return filterTickers
    }
}

