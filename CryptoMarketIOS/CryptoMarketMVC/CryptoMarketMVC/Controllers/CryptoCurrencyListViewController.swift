//
//  CryptoCurrencyListViewController.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 8/25/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit
import SafariServices

class CryptoCurrencyListViewController: UIViewController, SFSafariViewControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var expandedIndexPaths: Set<IndexPath> = []
    var expandViewController: ExpandViewController?
    
    var tickers = [String]()
    
    var cellIdentifier = "CurrencyCell2"
    
    @IBAction func presentSafariViewController(_ sender: Any) {
        if let url = URL(string: "http://google.com") {
            let vc = DetailViewController(url: url)
            vc.delegate = self
            
            present(vc, animated: true)
        }
    }
    
    private func safariViewControllerDidFinish(_ controller: DetailViewController) {
        dismiss(animated: true)
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickers.count
    }
    
    func _tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, with ticker: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CurrencyCell
        
        cell.setWithExpand(self.expandedIndexPaths.contains(indexPath))
        cell.setName(ticker)
        
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
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ticker = tickers[indexPath.row]
        
        return _tableView(tableView, cellForRowAt: indexPath, with: ticker)
    }

}

extension CryptoCurrencyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = UINib(nibName: "SectionHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? SectionHeaderView
        if let headerView = sectionHeaderView {
            headerView.delegate = self
            headerView.backgroundColor = .groupTableViewBackground
            return headerView
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
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

extension CryptoCurrencyListViewController: SectionHeaderViewDelegate {
    func sectionHeaderView(_ sectionHeaderView: SectionHeaderView, tap sortBy: SortBy) {
        Log.d("Tap \(sortBy)")
    }
}

