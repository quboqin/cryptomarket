//
//  SettingsViewController.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 8/25/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsViewController: UITableViewController {    
    let disposeBag = DisposeBag()
    
    let _switchKlineSource = PublishSubject<DataSource>()
    var didSwitchKlineSource: Observable<DataSource> { return _switchKlineSource.asObservable() }
    
    let _selectShowCoinOnly = PublishSubject<Bool>()
    var didSelectShowCoinOnly: Observable<Bool> { return _selectShowCoinOnly.asObservable() }
    
    let _selectRemoveMyFavorites = PublishSubject<Void>()
    var didSelectRemoveMyFavorites: Observable<Void> { return _selectRemoveMyFavorites.asObservable() }
    
    @IBOutlet weak var dataSourceSegment: UISegmentedControl!
    @IBOutlet weak var removeMyFavoriteButton: UIButton!
    @IBOutlet weak var showCoinOnlySwitch: UISwitch!
    
    private func setupBindings() {
        dataSourceSegment.rx.selectedSegmentIndex
            .map({ (index) -> DataSource in
                return DataSource(source: index)
            })
            .bind(to: _switchKlineSource)
            .disposed(by: disposeBag)
        
        didSwitchKlineSource
            .map({ (dataSource) -> Int in
                return dataSource.hashValue
            })
            .bind(to: dataSourceSegment.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)
        
        showCoinOnlySwitch.rx.isOn.changed
            .bind(to: _selectShowCoinOnly)
            .disposed(by: disposeBag)
        
        didSelectShowCoinOnly
            .bind(to: showCoinOnlySwitch.rx.isOn)
            .disposed(by: disposeBag)
        
        removeMyFavoriteButton
            .rx.tap
            .bind(to: _selectRemoveMyFavorites)
            .disposed(by: disposeBag)
        
        self.navigationItem.leftBarButtonItem?
            .rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // FIXED: How to make bidirectional binding between..., force load view
        _ = self.view
        
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = closeButton
        
        setupBindings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        dataSourceSegment.selectedSegmentIndex = KLineSource.shared.dataSource.hashValue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
