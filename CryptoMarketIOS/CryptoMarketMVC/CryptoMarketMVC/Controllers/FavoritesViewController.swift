//
//  FavoritesViewController.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 8/25/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class FavoritesViewController: CryptoCurrencyListViewController {
    var favoriteSectionHeaderView: SectionHeaderView?
    
    let favorietsRx = Variable<[Ticker]>([])
    
    func addTicker(_ ticker: Ticker) {
        if self.favorietsRx.value.contains(where: { $0.id == ticker.id }) {
            return
        }
        
        self.favorietsRx.value.append(ticker)
    }
    
    func bindingTableView(_ tickers: Variable<[Ticker]>) {
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
    
        
        let _tickers = Observable.combineLatest(tickers.asObservable(), self.favoriteSectionHeaderView!.sortingOrder) {
            (tickers_, sort) -> [Ticker] in
            return sortedBykey(tickers: tickers_, key: sort)
        }
        
        
        _tickers
            .map {
                return [SectionModel(model: "Coin", items: $0)]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
        
        //        dataSource.titleForHeaderInSection = { dataSource, index in
        //            return dataSource.sectionModels[index].model
        //        }
        dataSource?.canEditRowAtIndexPath = { dataSource, indexPath in
            return true
        }
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func setupBinding() {
        bindingTableView(favorietsRx)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.favoriteSectionHeaderView = UINib(nibName: "SectionHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? SectionHeaderView
        self.favoriteSectionHeaderView?.section = .favorite
        
        setupBinding()
        
//        self.getTickersFromDisk()
//        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.saveTickersToDisk()
    }
}

extension FavoritesViewController {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {        
        let favoriteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Remove", handler:{ [weak self] action, indexpath in
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self?.tableView.beginUpdates()
                self?.favorietsRx.value.remove(at: indexPath.row)
                self?.tableView.deleteRows(at: [indexPath], with: .right)
                self?.tableView.endUpdates()
            })
            CATransaction.commit()

        })

        return [favoriteRowAction]
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.favoriteSectionHeaderView == nil {
            if let headerView = super.tableView(tableView, viewForHeaderInSection: section) as? SectionHeaderView {
                headerView.section = SortSection.favorite
                self.favoriteSectionHeaderView = headerView
                return headerView
            }
        }
        return self.favoriteSectionHeaderView
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ticker = tickers[indexPath.row]
        return _tableView(tableView, cellForRowAt: indexPath, with: ticker)
    }
}

extension FavoritesViewController: SettingsViewControllerFavoriteDelegate {
    func settingsViewController(_ viewController: SettingsViewController, didRemoveMyFavorites isRemoveMyFavorites: Bool) {
        Log.v("Remove SaveMyFavorites \(isRemoveMyFavorites)")
       self.removeSavedJSONFileFromDisk()
       self.tableView.reloadData()
    }
}

extension FavoritesViewController {
    func getDocumentsURL() -> URL {
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url.appendingPathComponent("posts.json")
        } else {
            fatalError("Could not retrieve documents directory")
        }
    }
    
    func saveTickersToDisk() {
        let encoder = JSONEncoder()
        do {
            var _savedTickers = [SavedTicker]()
            tickers.forEach {
                _savedTickers.append(SavedTicker(id: $0.id, name: $0.name, symbol: $0.symbol, websiteSlug: $0.websiteSlug, rank: $0.rank, circulatingSupply: $0.circulatingSupply, totalSupply: $0.totalSupply, maxSupply: $0.maxSupply, quotes: $0.quotes, lastUpdated: $0.lastUpdated, fullName: $0.fullName, imageUrl: $0.imageUrl))
            }
            if _savedTickers.count == 0 {
                return
            }
            let savedTickers = SavedTickers(baseImageUrl: baseImageUrl, data: _savedTickers)
            let data = try encoder.encode(savedTickers)
            try data.write(to: getDocumentsURL(), options: [])
        } catch {
            Log.e("An error took place: \(error.localizedDescription)")
        }
    }
    
    func getTickersFromDisk() {
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: getDocumentsURL(), options: [])
            let savedTickers = try decoder.decode(SavedTickers.self, from: data)
            self.baseImageUrl = savedTickers.baseImageUrl
            let _savedTickers = savedTickers.data
            _savedTickers.forEach {
                let _ticker = $0
                if self.tickers.contains(where: { $0.id == _ticker.id }) {
                    return
                }
                self.tickers.append(Ticker(id: $0.id, name: $0.name, symbol: $0.symbol, websiteSlug: $0.websiteSlug, rank: $0.rank, circulatingSupply: $0.circulatingSupply, totalSupply: $0.totalSupply, maxSupply: $0.maxSupply, quotes: $0.quotes, lastUpdated: $0.lastUpdated, isToken: false, fullName: $0.fullName, url: "", imageUrl: $0.imageUrl))
            }
        } catch {
            Log.e("An error took place: \(error.localizedDescription)")
        }
    }
    
    func removeSavedJSONFileFromDisk() {
        let fileManager = FileManager.default
        do {
            if fileManager.fileExists(atPath: getDocumentsURL().path) {
                try fileManager.removeItem(at: getDocumentsURL())
                self.tickers = [Ticker]()
            } else {
                Log.v("File does not exist")
            }
        } catch let error as NSError {
            Log.e("An error took place: \(error.localizedDescription)")
        }
    }
}
