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
    
    let viewModel = FavoriteViewModel()
    
    override func setupBindings() {
        super.setupBindings()
        
        self.favoriteSectionHeaderView?.viewModel.didSelectSortingOrder
            .bind(to: viewModel.setSortOrder)
            .disposed(by: disposeBag)
        
        viewModel.newTicker
            .subscribe(onNext: { (newTicker) in
                if self.viewModel.tickers.value.contains(where: { $0.id == newTicker.id }) {
                    return
                }
                self.viewModel.tickers.value.append(newTicker)
            })
            .disposed(by: disposeBag)
        
        viewModel.removeIndex
            .subscribe(onNext: { (indexPath) in
                self.viewModel.tickers.value.remove(at: indexPath.row)
            })
            .disposed(by: disposeBag)
        
        viewModel.deleteFavoriteListAndFile
            .subscribe(onNext: {
                self.viewModel.tickers.value.removeAll()
                self.removeSavedJSONFileFromDisk()
            })
            .disposed(by: disposeBag)
        
        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
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
                self?.viewModel.removeIndex.onNext(indexPath)
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
            self.viewModel.tickers.value.forEach {
                 _savedTickers.append(SavedTicker(id: $0.id, name: $0.name, symbol: $0.symbol, quotes: $0.quotes, fullName: $0.fullName, imageUrl: $0.imageUrl))
            }

            if _savedTickers.count == 0 {
                return
            }
            let savedTickers = SavedTickers(baseImageUrl: GlobalStatus.shared.baseImageUrl.value, data: _savedTickers)
            let data = try encoder.encode(savedTickers)
            try data.write(to: getDocumentsURL(), options: [])
        } catch {
            Log.e("An error took place: \(error.localizedDescription)")
        }
    }
    
    func getTickersFromDisk() {
        let decoder = JSONDecoder()
        do {
            self.viewModel.tickers.value.removeAll()
            let data = try Data(contentsOf: getDocumentsURL(), options: [])
            let savedTickers = try decoder.decode(SavedTickers.self, from: data)
            GlobalStatus.shared.baseImageUrl.value = savedTickers.baseImageUrl
            let _savedTickers = savedTickers.data
            _savedTickers.forEach {
                let _ticker = $0
                if self.viewModel.tickers.value.contains(where: { $0.id == _ticker.id }) {
                    return
                }
                
                let ticker = Ticker(id: $0.id, name: $0.name, symbol: $0.symbol, websiteSlug: "", rank: 0, circulatingSupply: 0, totalSupply: 0, maxSupply: 0, quotes: $0.quotes, lastUpdated: 0, isToken: false, fullName: $0.fullName, url: "", imageUrl: $0.imageUrl)
                
                self.viewModel.tickers.value.append(CurrencyViewModel(currency: ticker))
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
            } else {
                Log.v("File does not exist")
            }
        } catch let error as NSError {
            Log.e("An error took place: \(error.localizedDescription)")
        }
    }
}
