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
    // share()
    
    rxInit()
  }
}

extension ViewController {
  func rxInit() {
    // RxSwift 자동완성이 잘되지 않음. asObservable() 사용하고 나서 자동완성이 잘됨
    let textToNumber: (String?) -> Observable<Int> =  { text -> Observable<Int> in
      guard let text = text, let value = Int(text) else { return Observable.empty() }
      
      return Observable.just(value)
    }
    
    // flatMap 문제점
    // - 첫 번째 버튼에 대한 이벤트가 3번 발생, 두 번째 버튼에 대한 이벤트가 3번 발생, 세 번째 버튼에 대한 이벤트가 3번 발생
    // - flatMap은 이벤트가 섞임. 이벤트가 섞이지 않도록 해야함
    // - 이 문제점을 해결하기 위해 flatMapFirst, flatMapLatest 있음
    
    // flatMapFirst
    // - 먼저 생성된 옵저버블이 끝나기 전까지 들어오는 이벤트는 무시함. 첫 번째 생성한 이벤트가 끝까지 일어남
    // - 스크롤를 통해 처음 내용을 불러올 때, 페이지 로딩이 필요할 때 사용할 수 있음
    // - API가 끝나기 전까지 다른 API를 부르지 않음
    
    // fiatMapLatest
    // - 이벤트가 들어오면 앞에 생성된 옵저버블을 무시함
    // - 세 번째 이벤트는 끝까지 일어남
    // - 예를 들어 카카오톡 외치기 같이 카톡에서 서버랑 유저의 정합성이 맞아야 하는 API는 아님. 빠르게 누르는 것이 중요함, Facebook Live 좋아요 같은 Reponse가 중요하지 않을 때 사용하는 것이 좋음
    let aValueObservable = aTextField.rx.text.asObservable().flatMap(textToNumber)
    let bValueObservable = bTextField.rx.text.asObservable().flatMap(textToNumber)
    let cValueObservable = cTextField.rx.text.asObservable().flatMap(textToNumber)
    
    // CombineLatest
    // - 두 개 Observable에서 가장 최근 발생한 이벤트를 합침. 이벤트 타입이 달라도 됨
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
    
    // interval의 내부 구현이 궁금하면 RxSwift -> Timer.swift 파일 확인
    // TimerSink 라는 클래스의 Run() 함수에서 run이 1회 돌때마다 state+ 1 을 리턴하는 코드를 확인할 수 있음
    // Observable<Int>.interval(0.5, scheduler: MainScheduler.instance).take(20).subscribe(subscriber).disposed(by: disposeBag)
    
    // Observable 자체로 새로운 이벤트를 추가하지 못함. 그래서 Subject가 필요함
    // let o1 = Observable<Int>.just(10)
    
    print("---")
    
    // Subject
    // - 수동적으로 새로운 값을 Observable에게 넣어주고 그 값을 Subscribers에게 값을 Emit해줘야 할 때가 있음. 결론은 Observable과 Observer처럼 둘 다 사용할 수 있도록 함
    // - Subject는 Subscribe하는 Subscriber들에게만 이벤트를 발생시켜줌. 구독한 후, 구독자들에게만 값을 전달해줌
    // PublishSubject
    // - Observer, Observable 동시 구현
    // - On, Subscribe 둘 다 할 수 있음
    // - Subscribe 후, Observable이 보낸 이벤트를 전달받음
    // - 스스로 일어나는 이벤트가 아닐 때 사용함 -> 이벤트를 외부에서 전달해주는 경우 사용함. Delegate로 사용할 수 있음
    // ReplaySubject
    // - Subscribe 전에 발생한 이벤트를 버퍼 사이즈 만큼 넣고, 버퍼에 있던 이벤트를 subscribe 후 전달함. 버퍼 크기를 설정한 만큼 구독 후 이벤트를 전달함
    // BehaviorSubject
    // - 초기값이 1개
    // - Subscribe 후, 최신 Event를 전달 받음
    // - Subscribe와 상관없이 데이터에 접근해서 사용해야 하는 경우 -> Datasource로 사용할 수 있음
    let publishSubject: PublishSubject<Int> = PublishSubject()
    publishSubject.onNext(1)
    publishSubject.onNext(3)
    publishSubject.subscribe(subscriber).disposed(by: disposeBag)
    publishSubject.onNext(20)
    publishSubject.onNext(22)
    
    print("---")
    
    let behaviorSubject: BehaviorSubject<Int> = BehaviorSubject(value: 200)
    behaviorSubject.onNext(100)
    behaviorSubject.subscribe(subscriber).disposed(by: disposeBag)
    behaviorSubject.subscribe(subscriber).disposed(by: disposeBag)
    behaviorSubject.onNext(300)
    behaviorSubject.onNext(400)
    
    // distinctUntilChange은 스크롤뷰나 GPS에서 위치가 바뀔 때 이전 값이랑 이후 값이랑 비교해서 어떤 조건에서 차이가 날 때 이벤트를 발생시킬 수 있거나
    // 롱 풀링하는 앱이 있다면 무언가 변화가 있을 때만 이벤트를 발생시킬 수 있는 함수
    
    // zip, merge, combineLastest 공통점은 같은 타입으로 리턴함
    // zip, merge, combineLastest 차이점
    // merge는 같은 이벤트 타입을 합침. 같은 이벤트를 합치기 때문에 이벤트 하나만 발생함
    // zip은 이벤트 한 쌍씩 합침
    // combineLastest은 Observable 객체들에서 이벤트가 발생할 때마다 가장 최근에 발생한 이벤트를 합침
  }
  
  func share() {
    // Observable 공유
    // - Observable을 공유하지 않으면 Subscribe횟수만큼 이벤트가 발생할 수 있음. 그래서 Observable 공유가 필요함
    let observable = Observable<Int>
      .interval(0.3, scheduler: MainScheduler.instance).take(2).skip(1)
      .map { (element: Int) -> Int in
        print("map: \(element)")
        return element
    }
    
    // Publish
    // - 일반 Observable를 공유 가능한 Observable로 변환함
    let publishObservable = observable.publish()
    
    publishObservable
      .subscribe(onNext: { element in
        print("publishObservable subscribe 1 : \(element)")
      }).disposed(by: disposeBag)
    
    publishObservable
      .subscribe(onNext: { element in
        print("publishObservable subscribe 2 : \(element)")
      }).disposed(by: disposeBag)
    
    // Connect
    // - Subscriber가 항목을 배출할 수 있도록 공유되어 있는 Observable에게 명령을 내림
    publishObservable.connect().disposed(by: disposeBag)
    
    // Connect를 사용하지 않아도 일반 Observable가 연결 가능한 Observable처럼 동작함
    let observable2 = Observable<Int>
      .interval(0.3, scheduler: MainScheduler.instance).take(3).skip(1)
      .map { (element: Int) -> Int in
        print("map: \(element)")
        return element
    }
    
    let refCountedPublishObservable = observable2.publish().refCount()
    
    refCountedPublishObservable
      .subscribe(onNext: { element in
        print("refCountedPublishObservable subscribe 1 : \(element)")
      }).disposed(by: disposeBag)
    
    refCountedPublishObservable
      .subscribe(onNext: { element in
        print("refCountedPublishObservable subscribe 2 : \(element)")
      }).disposed(by: disposeBag)
    
    
    // xs.subscribe 를 3번 만들면 새로운 Subscriber를 만듦. 결론은 3개 새로운 Subscriber가 생김. 3개에 대한 이벤트 생성 시간이 각각 다름
    let xs = Observable.deferred { () -> Observable<TimeInterval> in
      print("Performing work ...")
      return Observable.just(Date().timeIntervalSince1970)
      }.replay(1)
    
    _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
    _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
    _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
    xs.connect().disposed(by: disposeBag)
    
    
    let xs2 = Observable.deferred { () -> Observable<TimeInterval> in
      print("Performing work ...")
      return Observable.just(Date().timeIntervalSince1970)
      }
      // replay(1)를 통해 이벤트를 공유하고 있다가 1개를 반환함
      // refCount를 레퍼런스 카운팅라고 생각하면 쉬움. Subscribe 하면 refCount() 1이 되었다가 0이 됨
      .replay(1).refCount()
    
    _ = xs2.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
    _ = xs2.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
    _ = xs2.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
    
    // Observable이 이벤트 방출 후에 Subscribe 하더라도 방출한 모든 이벤트들을 볼 수 있음
    // func replay(_ bufferSize: Int) -> ConnectableObservable<E> {
    //   return self.multicast { ReplaySubject.create(bufferSize: bufferSize) }
    // }
    
    let xs3 = Observable.deferred { () -> Observable<TimeInterval> in
      return Observable.just(Date().timeIntervalSince1970)
    }
    // replay(1)를 통해 이벤트를 공유하고 있다가 1개를 반환함
    // refCount를 레퍼런스 카운팅라고 생각하면 됨. subscribe 하면 refCount() 1이 되었다가 0이 됨
    .replay(1).refCount()
    
    _ = xs3.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
    _ = xs3.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
    _ = xs3.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
    
    
    // Share - forever
    // - Observable를 공유하기 위해 사용함. 잘 사용하지 않음. 종료된 예전 값을 가져와서 사용하는 케이스가 잘 없음
    // - 채팅방에서 메세지 작업 중에서 메세지를 공유하기 위해서 share를 쓰는 것이 좋음
    // - replay 0인지 1인지 고민하면 됨
    // - TabelView가 있으면 DataSource에 Bind함. DataSource에 원 글과 댓글이 존재함. 댓글과 원글의 DataSource를 공유하기 위해 사용할 수도 있음
    
    // Share - whileConnected
    // - 생각보다 사용할 일이 없음
    // func share(replay: Int = 0, scope: SubjectLifetimeScope = .whileConnected)
    //   -> Observable<E> {
    //     switch scope {
    //     case .forever:
    //       switch replay {
    //       case 0: return self.multicast(PublishSubject()).refCount()
    //       default: return
    //         self.multicast(ReplaySubject.create(bufferSize: replay)).refCount()
    //       }
    //     case .whileConnected:
    //       switch replay {
    //       case 0: return ShareWhileConnected(source: self.asObservable())
    //       case 1: return ShareReplay1WhileConnected(source: self.asObservable())
    //       default: return self.multicast(makeSubject: {
    //         ReplaySubject.create(bufferSize: replay) }).refCount()
    //       }
    //     }
    // }
  }
}
