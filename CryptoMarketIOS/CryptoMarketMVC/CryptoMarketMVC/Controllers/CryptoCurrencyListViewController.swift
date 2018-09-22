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
    var expandViewController: ExpandViewController!
    
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
    
    func setupBindings() {
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Ticker>>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! CurrencyCell
                cell.selectionStyle = .none
                cell.setCoinImage(item.imageUrl, with: GlobalStatus.shared.baseImageUrl.value)
                cell.setName(item.fullName)
                cell.setPrice((item.quotes["USD"]?.price)!)
                cell.setChange((item.quotes["USD"]?.percentChange24h)!)
                cell.setVolume24h((item.quotes["USD"]?.volume24h)!)
                
                self.currentUrlString = GlobalStatus.shared.baseImageUrl.value + item.url
                
                cell.setWithExpand(self.expandedIndexPaths.contains(indexPath))
                
                if self.expandedIndexPaths.contains(indexPath) {
                    if self.expandViewController == nil {
                        self.expandViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExpandViewController") as? ExpandViewController

                        self.expandViewController.viewModel.setSymbol.onNext(item.symbol)
                        
                        GlobalStatus.shared.klineDataSource.asObservable().debug()
                            .bind(to: self.expandViewController.viewModel.setDataSource)
                            .disposed(by: self.disposeBag)
                    }
                    if let expandViewController = self.expandViewController {
                        self.addChild(expandViewController)
                        cell.embeddedView.addSubview(expandViewController.view)
                        
                        expandViewController.view.translatesAutoresizingMaskIntoConstraints = false
                        
                        NSLayoutConstraint.activate([
                            expandViewController.view.leadingAnchor.constraint(equalTo: cell.embeddedView.leadingAnchor),
                            expandViewController.view.trailingAnchor.constraint(equalTo: cell.embeddedView.trailingAnchor),
                            expandViewController.view.topAnchor.constraint(equalTo: cell.embeddedView.topAnchor),
                            expandViewController.view.bottomAnchor.constraint(equalTo: cell.embeddedView.bottomAnchor)
                            ])
                        
                        expandViewController.didMove(toParent: self)
                    }
                }
                
                return cell
        })
        
        dataSource?.canEditRowAtIndexPath = { dataSource, indexPath in
            return !self.expandedIndexPaths.contains(indexPath as IndexPath)
        }
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        func removeViewControllerBy(index: IndexPath) {
            self.expandedIndexPaths.remove(index)
            self.expandViewController?.willMove(toParent: self)
            self.expandViewController?.view.removeFromSuperview()
            self.expandViewController?.removeFromParent()
            self.expandViewController = nil
        }
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                var indexPaths = [IndexPath]()
                
                if(self?.expandedIndexPaths.contains(indexPath))! {
                    removeViewControllerBy(index: indexPath)
                } else {
                    if (self?.expandedIndexPaths.count)! > 0 {
                        let firstIndex = self?.expandedIndexPaths.removeFirst()
                        removeViewControllerBy(index: firstIndex!)
                        indexPaths.append(firstIndex!)
                    }
                    self?.expandedIndexPaths.insert(indexPath)
                }
                indexPaths.append(indexPath)
                
                self?.tableView.reloadRows(at: indexPaths, with: .automatic)
                self?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }).disposed(by: disposeBag)
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
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
}

extension CryptoCurrencyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}

extension CryptoCurrencyListViewController: SFSafariViewControllerDelegate {
    private func safariViewControllerDidFinish(_ controller: DetailViewController) {
        dismiss(animated: true)
    }
}
