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
  @IBOutlet weak var shareReplay0ForeverDelayButton: UIButton!
  @IBOutlet weak var shareReplay1ForeverDelayButton: UIButton!
  @IBOutlet weak var shareReplay2ForeverDelayButton: UIButton!
  
  @IBOutlet weak var shareReplay0WhileConnectedDelayButton: UIButton!
  @IBOutlet weak var shareReplay1WhileConnectedDelayButton: UIButton!
  @IBOutlet weak var shareReplay2WhileConnectedDelayButton: UIButton!
  
  var disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
  }
}

extension ConnectableObservablesViewController {
  func bind() {
    shareReplay0ForeverDelayButton.rx.tap.subscribe(onNext: {[weak self] _ in self?.shareReplay0ForeverDelay() }).disposed(by: disposeBag)
    shareReplay1ForeverDelayButton.rx.tap.subscribe(onNext: {[weak self] _ in self?.shareReplay1ForeverDelay() }).disposed(by: disposeBag)
    shareReplay2ForeverDelayButton.rx.tap.subscribe(onNext: {[weak self] _ in self?.shareReplay2ForeverDelay() }).disposed(by: disposeBag)
    shareReplay0WhileConnectedDelayButton.rx.tap
      .subscribe(onNext: {[weak self] _ in self?.shareReplay0WhileConnectedDelay() }).disposed(by: disposeBag)
    shareReplay1WhileConnectedDelayButton.rx.tap
      .subscribe(onNext: {[weak self] _ in self?.shareReplay1WhileConnectedDelay() }).disposed(by: disposeBag)
    shareReplay2WhileConnectedDelayButton.rx.tap
      .subscribe(onNext: {[weak self] _ in self?.shareReplay2WhileConnectedDelay() }).disposed(by: disposeBag)
  }
  
  func shareReplay0ForeverDelay() {
    print("==========================================\n")
    
    let observable : Observable<TimeInterval> = Observable<Int>.interval(0.1, scheduler: MainScheduler.instance)
      .take(4)
      .map { _ -> TimeInterval in return  Date().timeIntervalSince1970 }
      .share(replay: 0, scope: .forever)
    
    Observable<Int>.interval(0.11, scheduler: MainScheduler.instance).take(4).subscribe(onNext: { [weak self] count in
      guard let `self` = self else { return }
      print("subscribe: \(count)")
      observable.subscribe(onNext: { print("\(count) next \($0)")}).disposed(by: self.disposeBag)
    }).disposed(by: disposeBag)
  }
  
  func shareReplay1ForeverDelay() {
    print("==========================================\n")
    let observable : Observable<TimeInterval> = Observable<Int>.interval(0.1, scheduler: MainScheduler.instance)
      .take(4)
      
      .map { _ -> TimeInterval in return  Date().timeIntervalSince1970 }
      .share(replay: 1, scope: .forever)
    
    
    Observable<Int>.interval(0.11, scheduler: MainScheduler.instance).take(4).subscribe(onNext: { [weak self] count in
      guard let `self` = self else { return }
      print("subscribe: \(count)")
      observable.subscribe(onNext: { print("\(count) next \($0)")}).disposed(by: self.disposeBag)
    }).disposed(by: disposeBag)
  }
  
  func shareReplay2ForeverDelay() {
    print("==========================================\n")
    let observable : Observable<TimeInterval> = Observable<Int>.interval(0.1, scheduler: MainScheduler.instance)
      .take(4)
      
      .map { _ -> TimeInterval in return  Date().timeIntervalSince1970 }
      .share(replay: 2, scope: .forever)
    //            .debug()
    
    Observable<Int>.interval(0.15, scheduler: MainScheduler.instance).take(4).subscribe(onNext: { [weak self] count in
      guard let `self` = self else { return }
      print("subscribe: \(count)")
      observable.subscribe(onNext: { print("\(count) next \($0)")}).disposed(by: self.disposeBag)
    }).disposed(by: disposeBag)
  }
  
  func shareReplay0WhileConnectedDelay() {
    print("==========================================\n")
    let observable : Observable<TimeInterval> = Observable<Int>.interval(0.1, scheduler: MainScheduler.instance)
      .take(4)
      .map { _ -> TimeInterval in
        print("Event Emit!!!!")
        return Date().timeIntervalSince1970 }
      .share(replay: 0, scope: .whileConnected)
    
    
    Observable<Int>.interval(0.15, scheduler: MainScheduler.instance).take(4).subscribe(onNext: { [weak self] count in
      guard let `self` = self else { return }
      print("subscribe: \(count)")
      observable.subscribe(onNext: { print("\(count) next \($0)")}).disposed(by: self.disposeBag)
    }).disposed(by: disposeBag)
  }
  
  func shareReplay1WhileConnectedDelay() {
    print("==========================================\n")
    let observable : Observable<TimeInterval> = Observable<Int>.interval(0.1, scheduler: MainScheduler.instance)
      .take(4)
      
      .map { _ -> TimeInterval in return  Date().timeIntervalSince1970 }
      .share(replay: 1, scope: .whileConnected)

    
    Observable<Int>.interval(0.15, scheduler: MainScheduler.instance).take(4).subscribe(onNext: { [weak self] count in
      guard let `self` = self else { return }
      print("subscribe: \(count)")
      observable.subscribe(onNext: { print("\(count) next \($0)")}).disposed(by: self.disposeBag)
    }).disposed(by: disposeBag)
  }
  
  func shareReplay2WhileConnectedDelay() {
    print("==========================================\n")
    let observable : Observable<TimeInterval> = Observable<Int>.interval(0.1, scheduler: MainScheduler.instance)
      .take(4)
      
      .map { _ -> TimeInterval in return  Date().timeIntervalSince1970 }
      .share(replay: 2, scope: .whileConnected)
    
    Observable<Int>.interval(0.15, scheduler: MainScheduler.instance).take(4).subscribe(onNext: { [weak self] count in
      guard let `self` = self else { return }
      print("subscribe: \(count)")
      observable.subscribe(onNext: { print("\(count) next \($0)")}).disposed(by: self.disposeBag)
    }).disposed(by: disposeBag)
  }
}
