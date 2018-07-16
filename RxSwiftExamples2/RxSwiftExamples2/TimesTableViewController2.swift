//
//  TimesTableViewController2.swift
//  RxSwiftExamples2
//
//  Created by yuaming on 16/07/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TimesTableViewController2: UIViewController {
  @IBOutlet var numberButtons: [UIButton]!
  @IBOutlet weak var firstNumberLabel: UILabel!
  @IBOutlet weak var secondNumberLabel: UILabel!
  @IBOutlet weak var resultNumberLabel: UILabel!
  
  fileprivate var disposeBag: DisposeBag = DisposeBag()
  // 전역변수는 Functional Programming 특징 중에서 Side Effect 일으키지 않는 특징에 대해 위배됨
  // fileprivate var firstNumber: Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    firstNumberLabel.text = ""
    secondNumberLabel.text = ""
    resultNumberLabel.text = ""
    
    bind()
  }
}

extension TimesTableViewController2 {
  fileprivate func bind() {
    let numberObservables = numberButtons.enumerated().map { (index, button) -> Observable<Int> in
      button.rx.tap.map { index + 1 }
    }
    
    let numberObservable = Observable.merge(numberObservables)
    let firstNumberObservable = numberObservable.enumerated().filter { (index, element) -> Bool in
        return index % 2 == 0
      }.map { (_, number) -> Int in
        return number
      }
    
    let secondNumberObservable = numberObservable.enumerated().filter { (index, element) -> Bool in
        return index % 2 == 1
      }.map { (_, number) -> Int in
        return number
      }
    
    // let firstNumberObservable = numberObservable.take(1)
    // let secondNumberObservable = numberObservable.skip(1).take(1)
    
    // 전역 변수(self)에 접근하기 위해 do나 subscribe 사용하지만, Side Effect가 발생함
    // firstNumberObservable
    //   .do(onNext: { [weak self] (firstNumber) in
    //     self?.firstNumber = firstNumber
    //   }).map { "\($0)"}.bind(to: firstNumberLabel.rx.text).disposed(by: disposeBag)
    
    firstNumberObservable
      .map { "\($0)" }
      .bind(to: firstNumberLabel.rx.text)
      .disposed(by: disposeBag)
    
    secondNumberObservable
      .map { "\($0)" }
      .bind(to: secondNumberLabel.rx.text)
      .disposed(by: disposeBag)
    
    // secondNumberObservable
    //   .map { [weak self] (secondNumber) -> String in
    //     return "\((self?.firstNumber ?? 0) * secondNumber)"
    //   }.bind(to: resultNumberLabel.rx.text).disposed(by: disposeBag)
    
    // withLatestFrom: Side Effect를 없애주는 메서드
    secondNumberObservable
      .withLatestFrom(firstNumberObservable) { (second, first) -> Int in
        return second * first
      }
      .map { "\($0)" }
      .bind(to: resultNumberLabel.rx.text)
      .disposed(by: disposeBag)
  }
}
