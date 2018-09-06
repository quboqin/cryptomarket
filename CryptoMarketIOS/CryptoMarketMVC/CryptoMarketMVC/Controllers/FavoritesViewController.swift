//
//  FavoritesViewController.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 8/25/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit

class FavoritesViewController: CryptoCurrencyListViewController {
    func addTicker(_ ticker: String) {
        if self.tickers.contains(where: { $0 == ticker }) {
            return
        }
        
        self.tickers.append(ticker)
        self.tableView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FavoritesViewController {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let favoriteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Remove", handler:{ [weak self] action, indexpath in
            self?.tickers.remove(at: indexPath.row)
            self?.tableView.reloadData()
        })

        return [favoriteRowAction]
    }
}
