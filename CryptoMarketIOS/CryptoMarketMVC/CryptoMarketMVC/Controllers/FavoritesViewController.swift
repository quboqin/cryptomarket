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
    
    private let favoritesRx = Variable<[Ticker]>([])
    let selectRemoveMyFavorites = PublishSubject<Void>()
    
    func addTicker(_ ticker: Ticker) {
        if self.favoritesRx.value.contains(where: { $0.id == ticker.id }) {
            return
        }
        
        self.favoritesRx.value.append(ticker)
    }
    
    func bindingTableView(_ tickers: Variable<[Ticker]>) {
        let favorites = Observable.combineLatest(tickers.asObservable(), self.favoriteSectionHeaderView!.sortingOrder) {
            (tickers_, sort) -> [Ticker] in
            return self.sortedBykey(tickers: tickers_, key: sort)
        }
        
        favorites
            .map {
                return [SectionModel(model: "Name", items: $0)]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
    }
    
    override func setupBindings() {
        super.setupBindings()
        
        selectRemoveMyFavorites.subscribe(onNext: {
           self.removeSavedJSONFileFromDisk()
        }).disposed(by: disposeBag)
        
        bindingTableView(favoritesRx)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setupUI() {
        super.setupUI()
        
        self.favoriteSectionHeaderView = UINib(nibName: "SectionHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? SectionHeaderView
        self.favoriteSectionHeaderView?.section = .favorite
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBindings()
        
        self.getTickersFromDisk()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.saveTickersToDisk()
    }
}

extension FavoritesViewController {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {        
        let favoriteRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Remove", handler:{ [weak self] action, indexpath in
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self?.tableView.beginUpdates()
                self?.favoritesRx.value.remove(at: indexPath.row)
                self?.tableView.deleteRows(at: [indexPath], with: .right)
                self?.tableView.endUpdates()
            })
            CATransaction.commit()

        })

        return [favoriteRowAction]
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.favoriteSectionHeaderView
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
            self.favoritesRx.value.forEach {
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
            self.favoritesRx.value.removeAll()
            let data = try Data(contentsOf: getDocumentsURL(), options: [])
            let savedTickers = try decoder.decode(SavedTickers.self, from: data)
            self.baseImageUrl = savedTickers.baseImageUrl
            let _savedTickers = savedTickers.data
            _savedTickers.forEach {
                let _ticker = $0
                if self.favoritesRx.value.contains(where: { $0.id == _ticker.id }) {
                    return
                }
                self.favoritesRx.value.append(Ticker(id: $0.id, name: $0.name, symbol: $0.symbol, websiteSlug: $0.websiteSlug, rank: $0.rank, circulatingSupply: $0.circulatingSupply, totalSupply: $0.totalSupply, maxSupply: $0.maxSupply, quotes: $0.quotes, lastUpdated: $0.lastUpdated, isToken: false, fullName: $0.fullName, url: "", imageUrl: $0.imageUrl))
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
                self.favoritesRx.value.removeAll()
            } else {
                Log.v("File does not exist")
            }
        } catch let error as NSError {
            Log.e("An error took place: \(error.localizedDescription)")
        }
    }
}
