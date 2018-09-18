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
    
    let selectShowCoinOnly = PublishSubject<Bool>()
    var didSelectShowCoinOnly: Observable<Bool> { return selectShowCoinOnly.asObservable() }
    
    let selectRemoveMyFavorites = PublishSubject<Void>()
    var didSelectRemoveMyFavorites: Observable<Void> { return selectRemoveMyFavorites.asObservable() }
    
    private let _cancel = PublishSubject<Void>()
    var didCancel: Observable<Void> { return _cancel.asObservable() }
    
    @IBOutlet weak var dataSourceSegment: UISegmentedControl!
    @IBOutlet weak var removeMyFavoriteButton: UIButton!
    @IBOutlet weak var showCoinOnlySwitch: UISwitch!
    
    private func setupBindings() {
        dataSourceSegment.rx.selectedSegmentIndex
            .map({ (index) -> DataSource in
                return DataSource(source: index)
            })
            .bind(to: KLineSource.shared.dataSource)
            .disposed(by: disposeBag)
        
        // set the initial value of the segment control from the global singleton object, so I remove the 2-way binding here
//        KLineSource.shared.dataSource.asObservable()
//            .map({ (dataSource) -> Int in
//                return dataSource.hashValue
//            })
//            .bind(to: dataSourceSegment.rx.selectedSegmentIndex)
//            .disposed(by: disposeBag)
        
        showCoinOnlySwitch.rx.isOn.changed.debug()
            .bind(to: selectShowCoinOnly)
            .disposed(by: disposeBag)

        didSelectShowCoinOnly.debug()
            .bind(to: showCoinOnlySwitch.rx.isOn)
            .disposed(by: disposeBag)
        
//        (showCoinOnlySwitch.rx.isOn <-> _selectShowCoinOnly)
//            .disposed(by: disposeBag)
        
        removeMyFavoriteButton
            .rx.tap
            .bind(to: selectRemoveMyFavorites)
            .disposed(by: disposeBag)
        
        self.navigationItem.leftBarButtonItem?
            .rx.tap
            .bind(to: _cancel)
            .disposed(by: disposeBag)
         
        didCancel
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
        
        dataSourceSegment.selectedSegmentIndex = KLineSource.shared.dataSource.value.rawValue
        
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
