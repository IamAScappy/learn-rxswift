//
//  ViewController.swift
//  RxSwiftExamples2
//
//  Created by yuaming on 07/07/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
  @IBOutlet weak var aTextField: UITextField!
  @IBOutlet weak var bTextField: UITextField!
  @IBOutlet weak var cTextField: UITextField!
  @IBOutlet weak var resultLabel: UILabel!
  
  let disposeBag: DisposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // bind()
    
    rxInit()
  }
}

extension ViewController {
  func rxInit() {
    // RxSwift 자동완성이 잘 되지 않음. asObservable() 사용하고 나서 자동완성이 됨
    let textToNumber: (String?) -> Observable<Int> =  { text -> Observable<Int> in
      guard let text = text, let value = Int(text) else { return Observable.empty() }
      
      return Observable.just(value)
    }
    
    let aValueObservable = aTextField.rx.text.asObservable().flatMap(textToNumber)
    let bValueObservable = bTextField.rx.text.asObservable().flatMap(textToNumber)
    let cValueObservable = cTextField.rx.text.asObservable().flatMap(textToNumber)
    
    Observable.combineLatest([aValueObservable, bValueObservable, cValueObservable]) { (values) -> Int in
      return values.reduce(0, +)
    }.map { "\($0)" }.subscribe { [weak self] event in
      switch event {
      case .next(let value):
        self?.resultLabel.text = value
      default:
        break
      }
    }.disposed(by: disposeBag)
  }
}

extension ViewController  {
  func bind() {
    let subscriber: (Event<Int>) -> Void = { event in
      switch event {
      case let .next(element):
        print("\(element)")
      case .error(let error):
        print(error.localizedDescription)
      case .completed:
        print("completed")
      }
    }
    
    Observable<Int>.just(1).subscribe(subscriber).disposed(by: disposeBag)
    
    Observable<Int>.from([1,2,3,4,5]).subscribe(subscriber).disposed(by: disposeBag)
    
    Observable<Int>.of(1,2,3,4,5).subscribe(subscriber).disposed(by: disposeBag)
    
    // Completed 이벤트만 발생함
    Observable<Int>.empty().subscribe(subscriber).disposed(by: disposeBag)
    
    print("---")
    
    // 이벤트가 발생하지 않음
    Observable<Int>.never().subscribe(subscriber).disposed(by: disposeBag)
    
    // RxError, RxCocoaError를 사용할 수 있음
    Observable<Int>.error(RxError.timeout).subscribe(subscriber).disposed(by: disposeBag)
    
    Observable<Int>.create { observer -> Disposable in
      observer.onNext(1)
      observer.on(Event.next(2))
      observer.onNext(6)
      observer.onNext(7)
      observer.onNext(8)
      observer.onCompleted()
      
      // Disposables.create { } dispose 될 때 실행시키고 싶은 코드가 있을 때 사용함
      return Disposables.create {
        // observer.onCompleted() 주석처리 하는 경우 출력이 되지 않음
        // error, complete,
        print("Dispose :)")
      }
    }.subscribe(subscriber).disposed(by: disposeBag)
  
    // take의 카운트가 해제되는 시점은 Completed 이벤트 발생할 때임
    Observable<Int>.repeatElement(1000).take(10).subscribe(subscriber).disposed(by: disposeBag)
    
    // interval의 내부 구현이 궁금하면 RxSwift => Timer.swift 파일 열어봄
    // TimerSink 라는 클래스의 Run() 함수에서 run이 1회 돌때마다 state+ 1 을 리턴하는 코드를 확인할 수 있음
    // Observable<Int>.interval(0.5, scheduler: MainScheduler.instance).take(20).subscribe(subscriber).disposed(by: disposeBag)
    
    // Observable 자체는 새로운 이벤트를 추가하지 못함. 그래서 Subject 설명
    // let o1 = Observable<Int>.just(10)
    
    print("---")
    
    let publishSubject: PublishSubject<Int> = PublishSubject()
    publishSubject.onNext(1)
    publishSubject.onNext(3)
    publishSubject.subscribe(subscriber).disposed(by: disposeBag)
    publishSubject.onNext(20)
    publishSubject.onNext(22)
    
    print("---")
    
    // 이벤트 하나를 저장하다가 Subscribe 하는 시점에서 이벤트를 발생시킴
    // TableView에서 Cell 선택하는 시점에서 이벤트를 가져올 때 사용할 수 있음
    let behaviorSubject: BehaviorSubject<Int> = BehaviorSubject(value: 200)
    behaviorSubject.onNext(100)
    behaviorSubject.subscribe(subscriber).disposed(by: disposeBag)
    behaviorSubject.subscribe(subscriber).disposed(by: disposeBag)
    behaviorSubject.onNext(300)
    behaviorSubject.onNext(400)
    
    // distinctUntilChange은 스크롤뷰나 GPS에서 위치가 바뀔 때 이전 값이랑 이후 값이랑 비교해서 어떤 조건에서 차이가 날 때 이벤트를 발생시킬 수 있거나
    // 롱 폴링하는 앱이 있다면 무언가 변화가 있을 때만 이벤트를 발생시킬 수 있는 함수
    
    // zip, merge, combineLastest 공통점은 같은 타입으로 리턴함
    // zip, merge, combineLastest 차이점
    // merge는 같은 이벤트 타입을 합침. 같은 이벤트를 합치기 때문에 이벤트 하나만 발생함
    // zip은 이벤트 한 쌍씩 합침
    // combineLastest은 Observable 객체들에서 이벤트가 발생할 때마다 가장 최근에 발생한 이벤트를 합침
  }
}
