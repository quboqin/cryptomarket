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

// 2-way binding example
//infix operator <->
//
//@discardableResult func <-><T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
//    let variableToProperty = variable.asObservable()
//        .bind(to: property)
//
//    let propertyToVariable = property
//        .subscribe(
//            onNext: { variable.value = $0 },
//            onCompleted: { variableToProperty.dispose() }
//    )
//
//    return Disposables.create(variableToProperty, propertyToVariable)
//}

class SettingsViewController: UITableViewController {    
    let disposeBag = DisposeBag()
    
    let viewModel = SettingViewModel()
    
    @IBOutlet weak var dataSourceSegment: UISegmentedControl!
    @IBOutlet weak var removeMyFavoriteButton: UIButton!
    @IBOutlet weak var showCoinOnlySwitch: UISwitch!
    
    private func setupBindings() {
        dataSourceSegment.rx.selectedSegmentIndex.changed
            .map({ (index) -> DataSource in
                return DataSource(source: index)
            }).debug()
            .bind(to: viewModel.selectDataSource)
            .disposed(by: disposeBag)
        
        viewModel.didSelectDataSource
            .map({ (dataSource) -> Int in
                return dataSource.rawValue
            }).debug()
            .bind(to: dataSourceSegment.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)
        
        showCoinOnlySwitch.rx.isOn.changed.debug()
            .bind(to: viewModel.selectShowCoinOnly)
            .disposed(by: disposeBag)

        viewModel.didSelectShowCoinOnly.debug()
            .bind(to: showCoinOnlySwitch.rx.isOn)
            .disposed(by: disposeBag)
        
//        (showCoinOnlySwitch.rx.isOn <-> _selectShowCoinOnly)
//            .disposed(by: disposeBag)
        
        removeMyFavoriteButton
            .rx.tap
            .bind(to: viewModel.selectRemoveMyFavorites)
            .disposed(by: disposeBag)
        
        self.navigationItem.leftBarButtonItem?
            .rx.tap
            .bind(to: viewModel.cancel)
            .disposed(by: disposeBag)
         
        viewModel.didCancel
            .subscribe(onNext: {
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // FIXED: How to save the status..., force load view
        _ = self.view
        
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = closeButton
        
        setupBindings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
