//
//  SectionHeaderViewModel.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 9/23/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import Foundation
import RxSwift
import RxGesture

class SectionHeaderViewModel {
    // MARK: - Inputs
    var sortOrderSubjects = [AnyObserver<UITapGestureRecognizer>]()
    
    // MARK: - Status
    
    // MARK: - Outputs
    var didSelectOrderSubjects = [Observable<SortOrder>]()
    let didSelectSortingOrder: Observable<SortOrder>
    
    init(section: SortSection) {
        let _sortOrderSubjects = [PublishSubject<UITapGestureRecognizer>(), PublishSubject<UITapGestureRecognizer>(), PublishSubject<UITapGestureRecognizer>()]
        
        for (index, _sortOrderSubject) in _sortOrderSubjects.enumerated() {
            let sortKey = SortKey(key: index)
            self.sortOrderSubjects.append(_sortOrderSubject.asObserver())
            let observable = _sortOrderSubject.asObservable().scan(SortOrder.none) { lastValue, _ in
                if case SortOrder.ascend(let _section, let _key) = lastValue {
                    return SortOrder.descend(_section, _key)
                }
                if case SortOrder.descend(let _section, let _key) = lastValue {
                    return SortOrder.ascend(_section, _key)
                }
                return SortOrder.ascend(section, sortKey)
            }
            self.didSelectOrderSubjects.append(observable)
        }
        
        didSelectSortingOrder = Observable.from(didSelectOrderSubjects).merge()
    }
}
