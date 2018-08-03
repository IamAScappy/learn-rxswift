//
//  TimesTableViewController1.swift
//  RxSwiftExamples2
//
//  Created by yuaming on 15/07/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimesTableViewController1: UIViewController {
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var label: UILabel!
  fileprivate let disposeBag: DisposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
  }
}

extension TimesTableViewController1 {
  fileprivate func bind() {
    // ControlProperty: orEmpty 프로퍼티가 존재함. Optional 중에서 nil인 경우 이벤트가 발생하지 않음
    // map을 사용하면 Observable이 아니라 nil를 리턴함. flatMap을 사용하면 Observable를 리턴해야 함
    textField.rx.text.orEmpty.flatMap { text -> Observable<Int> in
      guard let intValue = Int(text) else { return Observable.empty() }
      
      return Observable.just(intValue)
    }.flatMap { dan -> Observable<String> in
      // range를 통해 9개 이벤트가 발생하고 한개를 합침
      return Observable<Int>.range(start: 1, count: 9).map { step -> String in
        return "\(dan) * \(step) = \(dan * step)"
        // Array, Dictionary가 가지고 있는 reduce 메서드 동작과 비슷함
        }.reduce("", accumulator: { (answer, next) -> String in
          return answer + "\n" + next
        })
    }
    /*
    .subscribe(onNext: { [weak self] (result) in
      // print("\(result)"): print 대신 debug 메서드를 사용해서 출력해서 확인할 수 있음 }.debug("int: ").subscribe(onNext: { (result) in
      // [weak self] 붙이는 이유는 self가 nil이 날 수 있기 때문임
      self?.label.text = result
    })
     */
    // subscribe에서 결과를 바인드 하는 것과 같은 역할을 함
    // bind는 subscribe wrapper 지만, 실질적으로 값 바인딩 하나밖에 못하지만, subscribe에서 여러가지 일을 할 수 있다는 차이점이 있음
    .bind(to: label.rx.text)
    .disposed(by: disposeBag)
  }
}
