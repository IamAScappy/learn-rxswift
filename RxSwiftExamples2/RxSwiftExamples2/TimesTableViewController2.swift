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
  
  fileprivate let disposeBag: DisposeBag = DisposeBag()
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
    
    // Merge
    // - 이벤트 타입이 같은 Observable 여러 개를 합침. 합쳐진 이벤트는 이벤트 타입이 같은 것을 합쳤기 때문에 하나의 이벤트만 발생함
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
    
    // Side Effect가 있으면 안되는 곳
    // - map
    // - flatMap
    // - 다른 형태로 바꾸는 것이기 때문에 Side Effect가 발생하면 안됨
    // Side Effect가 있어도 괜찮은 곳
    // - do
    // - Subscribe ⇒ Subscribe하기 때문에 self 접근이 가능함
    
    // 클로저 처리와 인자로 처리하는 차이
    
    /*
    
    // Side Effect가 발생할 수 있음
    sendButton.rx.tap.flatMap { [weak self] in
     
      // 클로저 외부를 직접 전급
      send(message: self?.textField.text)
    }
    
    // withLatestFrom
    // - Side Effect 해소
    // - 두 개 Observable를 합성하지만 하나 Observable에서 이벤트가 발생할 때 합성함. 이벤트가 발생하지 않으면 건너뜀
    sendButton.rx.tap
     
      // 인자로 넣음
      .withLatestFrom(textField.rx.text)
      .flatMap { message in
        // 텍스트 매개변수로 받아옴
        send(message: message)
    }
    */
    
    secondNumberObservable
      .withLatestFrom(firstNumberObservable) { (second, first) -> Int in
        return second * first
      }
      .map { "\($0)" }
      .bind(to: resultNumberLabel.rx.text)
      .disposed(by: disposeBag)
  }
}
