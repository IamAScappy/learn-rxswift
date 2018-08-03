//
//  ConnectableObservablesViewController.swift
//  RxSwiftExamples2
//
//  Created by yuaming on 2018. 8. 2..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ConnectableObservablesViewController: UIViewController {
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
  }
}

extension ConnectableObservablesViewController {
  fileprivate func bind() {
    let xs = Observable.deferred { () -> Observable<TimeInterval> in
      return Observable.just(Date().timeIntervalSince1970, scheduler: MainScheduler.instance)
    }.replay(2).refCount()
    
    _ = xs.subscribe(onNext: { print( "\($0)") }, onCompleted: { print("Completed") }).disposed(by: disposeBag)
    _ = xs.subscribe(onNext: { print( "\($0)") }, onCompleted: { print("Completed") }).disposed(by: disposeBag)
    _ = xs.subscribe(onNext: { print( "\($0)") }, onCompleted: { print("Completed") }).disposed(by: disposeBag)
    
    print("------------------------------------------\n\n\n")

    let xs1 = Observable.deferred { () -> Observable<TimeInterval> in
        return Observable.just(Date().timeIntervalSince1970).delay(0.1, scheduler: MainScheduler.instance)
      }
    
    _ = xs1.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") }).disposed(by: disposeBag)
    _ = xs1.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") }).disposed(by: disposeBag)
    _ = xs1.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") }).disposed(by: disposeBag)
  }
}
