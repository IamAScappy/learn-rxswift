//
//  TimesTableViewController3.swift
//  RxSwiftExamples2
//
//  Created by yuaming on 18/07/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimesTableViewController3: UIViewController {
  @IBOutlet weak var firstNumberLabel: UILabel!
  @IBOutlet weak var secondNumberLabel: UILabel!
  @IBOutlet weak var OLabel: UILabel!
  @IBOutlet weak var XLabel: UILabel!
  @IBOutlet weak var inputtedNumberLabel: UILabel!
  @IBOutlet var numberButtons: [UIButton]!
  
  @IBOutlet weak var startedButton: UIButton!
  
  fileprivate let disposeBag: DisposeBag = DisposeBag()
  fileprivate var answer: Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initialize()
    bind()
  }
  
  fileprivate func initialize() {
    firstNumberLabel.text = ""
    secondNumberLabel.text = ""
    inputtedNumberLabel.text = ""
    OLabel.alpha = 0
    XLabel.alpha = 0
  }
}

extension TimesTableViewController3 {
  fileprivate func bind() {
    let numberObservables = numberButtons.enumerated().map { (index, button) in
      button.rx.tap.map { index }
    }
    
    let numberObservable = Observable.merge(numberObservables)
    
    // Window, Buffer와 아주 밀접함. 거의 같지만 다른 점은 Observable 방출한다는 차이점이 존재함
    // - 이벤트 합치기 용도
    // - 앞부분에서 Subscribe, 뒷부분에서 Completed. 그래서 시작과 끝부분을 이용할 수 있음
    // Window 단위로 끊어짐. Window를 작은 Observable를 생각하면 됨
    
    // Scan
    // - 이전 이벤트와 현재 들어온 이벤트를 가지고 현재 발행할 새 이벤트를 만듦
    // - Answer ⇒ 이전 값
    // - Element ⇒ 현재 값
    // - Window로 비밀번호 자리수로 확인할 수 있음. Scan + Window 조합
    let inputtedNumberObservable = numberObservable.window(timeSpan: 3600 * 24, count: 2, scheduler: MainScheduler.instance).flatMap { window -> Observable<Int> in
      return window.scan(0, accumulator: { (anwser, event) -> Int in
        return (anwser * 10) + event
      })
    }
    
    inputtedNumberObservable
      .map { "\($0)" }
      .bind(to: inputtedNumberLabel.rx.text)
      .disposed(by: disposeBag)
    
    let timer = startedButton.rx.tap.do (onNext: { [weak self] _ in
        self?.initialize()
      }).flatMap { _ in
        return Observable<Int>
                .interval(1, scheduler: MainScheduler.instance)
                .map { _ -> Int in (Int(arc4random_uniform(9)) + 1) }.take(2)
      }
    
    timer.enumerated()
      .filter { return $0.index % 2 == 0}
      .map { $0.element }
      .do(onNext: { [weak self] (number) in
        guard let `self` = self else { return }
        self.answer = number
      })
      .map { "\($0)" }
      .bind(to: firstNumberLabel.rx.text)
      .disposed(by: disposeBag)
    
    timer.enumerated()
      .filter { return $0.index % 2 == 1 }
      .map { $0.element }
      .do(onNext: { [weak self] (number) in
        guard let `self` = self else { return }
        self.answer = self.answer * number
      })
      .map { "\($0)" }
      .bind(to: secondNumberLabel.rx.text)
      .disposed(by: disposeBag)
    
    inputtedNumberObservable.subscribe (onNext: { [weak self] number in
      guard let `self` = self else { return }
      
      if self.answer == number {
        self.OLabel.alpha = 1
        self.XLabel.alpha = 0
      } else {
        self.OLabel.alpha = 0
        self.XLabel.alpha = 1
      }
    }).disposed(by: disposeBag)
  }
}
