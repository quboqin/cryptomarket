//
//  ExpandViewModel.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 9/22/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation
import RxSwift

class ExpandViewModel {
    let disposeBag = DisposeBag()
    
    // MARK: - Inputs
    let setSymbol: AnyObserver<String>
    let setDataSource: AnyObserver<DataSource>
    
    // MARK: - Status
    
    // MARK: - Outputs
    let didSetSymbol: Observable<String>
    let didSetDataSource: Observable<DataSource>
    let histoHourVolumes = Variable<[OHLCV]>([])

    init(viewController: ExpandViewController) {
        let _dataSource = PublishSubject<DataSource>()
        self.setDataSource = _dataSource.asObserver()
        self.didSetDataSource = _dataSource.asObservable()
        
        let _symbol = PublishSubject<String>()
        self.setSymbol = _symbol.asObserver()
        self.didSetSymbol = _symbol.asObservable()
        
        // Trigger is KLineSource.shared.dataSources
        didSetDataSource.distinctUntilChanged().debug()
            .filter { (dataSource) -> Bool in
                return dataSource == DataSource.cryptoCompare
            }
            .withLatestFrom(didSetSymbol.debug()) { (dataSource, symbol) in
                return symbol
            }
            .flatMap { (symbol) -> Observable<HistoHourResponse> in
                return CryptoCompareNetworkManager.shared.getDataFromEndPointRx(.histohour(fsym: symbol, tsym: "USD", limit: 11), type: HistoHourResponse.self)
            }
            .map { (histoHourResponse) -> [OHLCV] in
                return histoHourResponse.data
            }
            .bind(to: histoHourVolumes)
            .disposed(by: disposeBag)
    
        
        didSetDataSource.distinctUntilChanged()
            .filter { (dataSource) -> Bool in
                return dataSource == DataSource.houbi
            }
            .withLatestFrom(didSetSymbol) { (dataSource, symbol) in
            return symbol
            }
            .flatMap { (symbol) ->  Observable<Event<KlineResponse>> in
                return HuobiNetworkManager.shared.getDataFromEndPointRx(.historyKline(symbol: symbol.lowercased() + "usdt", period: "5min", size: 150), type: KlineResponse.self).materialize()
            }
            .filter {
                guard $0.error == nil else {
                    Log.e("Catch Error: +\($0.error!)")
                    viewController.showAlert()
                    viewController.viewModel.histoHourVolumes.value = [OHLCV]()
                    return false
                }
                return true
            }
            .dematerialize()
            .map { (kLineResponse) -> [KlineItem] in
                return kLineResponse.data
            }
            .map { (kLineItems) -> [OHLCV] in
                var ohlcvs = [OHLCV]()
                kLineItems.forEach({ (kLineItem) in
                    let ohlcv = OHLCV(time: 0, open: kLineItem.open!, close: kLineItem.close!, low: kLineItem.low!, high: kLineItem.high!, volumefrom: 0.0, volumeto: 0.0)
                    ohlcvs.append(ohlcv)
                })
                return ohlcvs
            }
            .bind(to: histoHourVolumes)
            .disposed(by: disposeBag)
    }
}
