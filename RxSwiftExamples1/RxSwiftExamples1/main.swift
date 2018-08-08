//
//  main.swift
//  RxMacos
//
//  Created by JK on 03/08/2018.
//  Copyright © 2018년 yuaming. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


var disposeBag = DisposeBag()

func loadText(from filename: String) -> Single<String> {
  return Single.create { single in
    let disposable = Disposables.create()
    
    guard let path = Bundle.main.path(forResource: filename, ofType: "txt") else {
      single(.error(FileReadError.fileNotFound))
      return disposable
    }
    
    guard let data = FileManager.default.contents(atPath: path) else {
      single(.error(FileReadError.unreadable))
      return disposable
    }
    
    guard let contents = String(data: data, encoding: .utf8) else {
      single(.error(FileReadError.encodingFailed))
      return disposable
    }
    
    single(.success(contents))
    
    return disposable
  }
}

/*
 * Observable
 
 1. just
 - Observable의 타입 메서드. Observable Sequence를 만듦
 
 2. of
 - 컴파일러가 타입을 추론하여 Observable Sequence를 만듦
 
 3. from
 - Obserable<String>. Array 요소를 하나씩 배출함. Array 인자만 가짐
 */
example(of: "Create observable") {
  _ = Observable<String>.just(woong)
  
  _ = Observable.of(woong, gamja, sj)    // String Type
  _ = Observable.of([woong, gamja, sj])  // Array Type
  
  _ = Observable.from([woong, gamja, sj])
}

/*
 * Subscribe
 
 - Observable은 Subscribe 없이 아무것도 하지 못함. Observable은 Subscribe가 있어야 이벤트가 발생함.
 - Next Event를 통해 Observable 요소들이 방출되고 완료가 되면 Complete Event를 호출함. 원하는 값에 대해 접근할 수 있으며 이때 값은 옵셔널 형태임
 - Subscribe가 반환하는 값 타입은 Disposable임
 - onNext, onError, onCompleted 각자 원하는 값만 취함
 */
example(of: "Subscribe") {
  Observable.of(woong, gamja, sj).subscribe(onNext: { element in
    print(element)
  })
}

/*
 * Empty
 
 - Completed만 방출함
 - 의도적으로 아무런 타입이 아닌 Observable를 반환할 때 사용함
 */
example(of: "Empty") {
  Observable<Void>.empty().subscribe(onNext: { element in
    print(element)
  }, onCompleted: {
    print("Completed")
  })
}


example(of: "Never") {
  Observable<Any>.never().subscribe(onNext: { element in
    print(element)
  }, onCompleted: {
    print("Completed")
  })
}

/*
 * Dispose, DisposeBag
 
 - Observable의 사용이 끝나면 메모리 해제하거나 이벤트 방출을 취소할 때 dispose()를 호출함
 - 그러나, 직접 호출 하는 것은 좋은 코드가 아님
 - 직접 dispose() 호출하거나 DisposeBag에 담아서 disposed() 호출하지 않으면 메모리 릭이 발생함
 */
example(of: "Dispose") {
  Observable.of(woong, gamja, sj).subscribe { event in
    print(event)
  }.dispose()
}

example(of: "DisposeBag") {
  Observable.of(woong, gamja, sj).subscribe {
    print($0)
  }.disposed(by: disposeBag)
}


/*
 * Create
 
 - Create를 이용하여 Observable를 만들 수 있음
 - onError 이벤트가 발생하면 Dispose 되는 것을 확인할 수 있음. 즉 메모리가 해제된다는 것을 알 수 있음
 - 만약, Error, Complete도 발생하지 않고 Dispose도 없다면 컴파일러가 메모리 릭이 발생하는 것을 경고함
 */
example(of: "Create") {
  Observable<String>.create { observer in
    observer.onNext("R2-D2")
    observer.onError(Droid.OU812)
    observer.onNext("C-3PO")
    observer.onNext("K-2SO")
    observer.onCompleted()
    
    return Disposables.create()
  }.subscribe(
    onNext: { print($0) },
    onError: { print("Error:", $0) },
    onCompleted: { print("Completed") },
    onDisposed: { print("Disposed") }
  ).disposed(by: disposeBag)
}

/*
 * Do
 
 - do를 통해 부수효과를 추가할 수 있음. 하지만 이벤트 방출에 영향을 주지 않음. 왜냐하면 subscribe 가지고 있지 않기 때문임
 */
example(of: "Do") {
  // empty, subscribe와 never의 do 출력결과 순서가 미묘하게 다른 이유?
  
  // let observable = Observable.of(test1, test2, test4)
  // let observable = Observable<Any>.never()
  let observable = Observable<Void>.empty()
  
  observable.do (
    onSubscribe: {
      print("Do: About to subscribe")
  },onDispose: {
    print("Do: Disposed")
  }).subscribe(
    onNext: { element in
      print(element)
  }, onCompleted: {
    print("Subscribe: Completed")
  }, onDisposed: {
    print("Subscribe: Disposed")
  }).disposed(by: disposeBag)
}

/*
 * Trait
 
 1. Single
 - One Next Event or Error Event
 - http://reactivex.io/documentation/single.html
 
 2. Completable
 - Completed Event or Error Event
 - https://github.com/ReactiveX/RxSwift/blob/master/Documentation/Traits.md#creating-a-completable
 
 3. Maybe
 - One Next, Completed Event or Error Event
 - https://github.com/ReactiveX/RxSwift/blob/master/Documentation/Traits.md#creating-a-maybe
 */
example(of: "Single") {
  loadText(from: "ANewHope").subscribe {
    switch $0 {
    case .success(let string):
      print(string)
    case .error(let error):
      print(error)
    }
  }.disposed(by: disposeBag)
}


/*
 * Subject
 
 - Observable 과 Observer 둘 다 될 수 있음
 - Observables을 구독할 수 있고 다시 방출할 수 도 있음. 혹은 새로운 Observable을 방출할 수 있음
 */

/*
 * PublishSubject
 
 - Subscribe 전 이벤트는 방출하지 않음. Subscribe 후 이벤트만 방출함
 - 어떤 이벤트가 종료가 되었다는 것을 알릴 때 사용하면 유용함
 */
example(of: "PublishSubject") {
  let quotes = PublishSubject<String>()
  
  quotes.onNext(itsNotMyFault)
  
  let subscriptionOne = quotes.subscribe {
    print(label: "1)", event: $0)
  }
  
  quotes.on(.next(doOrDoNot))
  
  let subscriptionTwo = quotes.subscribe {
    print(label: "2)", event: $0)
  }
  
  subscriptionOne.dispose()
  
  quotes.onNext(eyesCanDeceive)
  
  // Subject가 종료한 후, 새로운 Subscriber가 생긴다고 다시 subject가 작동하지 않지만 Completed 이벤트만 방출함
  quotes.onCompleted()
  
  quotes.onNext(lackOfFaith)
  quotes.onNext(mayTheForceBeWithYou)
  
  let subscriptionThree = quotes.subscribe {
    print(label: "3)", event: $0)
  }
  
  quotes.onNext(stayOnTarget)
  
  subscriptionTwo.dispose()
  subscriptionThree.dispose()
}

/*
 * BehaviorSubject
 
 - PublishSubject와 거의 비슷함 BehaviorSubject는 반드시 값으로 초기화를 해줘야 함
 - 즉, Observer에게 구독하기 전 마지막 이벤트 혹은 초기값을 방출함
 */
example(of: "BehaviorSubject") {
  let quotes = BehaviorSubject<String>(value: iAmYourFather)
  
  quotes.subscribe {
    print(label: "1)", event: $0)
  }
  
  quotes.onNext(itsNotMyFault)
  quotes.onNext(eyesCanDeceive)
  // quotes.onError(Quote.neverSaidThat)
  quotes.onCompleted()
  
  quotes.subscribe {
    print(label: "2)", event: $0)
  }.disposed(by: disposeBag)
}

/*
 * ReplaySubject
 
 - 미리 정해진 사이즈 만큼 가장 최근의 이벤트를 새로운 Subscriber에게 전달함
 */
example(of: "ReplaySubject") {
  disposeBag = DisposeBag()
  
  let subject = ReplaySubject<String>.create(bufferSize: 2)
  
  subject.onNext(eyesCanDeceive)
  subject.subscribe {
    print(label: "1)", event: $0)
  }.disposed(by: disposeBag)
  
  subject.onNext(iAmYourFather)
  subject.onNext(itsNotMyFault)
  subject.onNext(mayThe4thBeWithYou)
  
  // 버퍼 사이즈가 2이기 때문에 최근 이벤트 2개를 새로운 구독자에게 전달함
  /*
   --- Example of: ReplaySubject ---
   1) Your eyes can deceive you. Don’t trust them.
   1) Luke, I am your father
   1) It’s not my fault.
   1) May the 4th be with you.
   2) It’s not my fault.
   2) May the 4th be with you.
   */
  subject.subscribe {
    print(label: "2)", event: $0)
  }.disposed(by: disposeBag)
}

example(of: "BehaviorRelay") {
  /*
   * Variable / BehaviorRelay
   
   - BehaviorSubject Wrapper 함수. Stateful 하기 때문에 Observable 현재 값을 확인할 수 있음
   - Variable은 Error 이벤트를 방출하지 않음. deinit에서 해제되며 Completed 이벤트를 방출하기 때문에 수동으로 Completed 이벤트를 추가할 필요가 없음
   
   - RxSwift 4.0에서 Variable DEPRECATED 됨
   - BehaviorRelay를 사용하자. Error나 Completed에서 종료하지 않음
   */
  // let variable = Variable(mayThe4thBeWithYou)
  let behaviorRelay = BehaviorRelay(value: mayThe4thBeWithYou)
  behaviorRelay.asObservable().subscribe {
    print(label: "1)", event: $0)
  }.disposed(by: disposeBag)
  
  // variable.value = mayThe4thBeWithYou
  // variable.value = MyError.anError
  // variable.asObservable().onError(MyError.anError)
  // variable.asObservable().onCompleted()
  
  // behaviorRelay.value = mayThe4thBeWithYou
}



example(of: "Defer, Replay, RefCount") {
  let xs = Observable.deferred { () -> Observable<TimeInterval> in
    print("Performing work...")
    return Observable.just(Date().timeIntervalSince1970).delay(0.1, scheduler: MainScheduler.instance)
  }.replay(1).refCount().debug("Defer Replay Refcount")
  
  _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
  _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
  _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
}

example(of: "Deffered no refcount") {
  let xs = Observable.deferred { () -> Observable<TimeInterval> in
    print("Performing work...")

      return Observable.just(Date().timeIntervalSince1970).delay(0.1, scheduler: MainScheduler.instance).debug("deffered no refcount")
    }
  
  _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
  _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
  _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
}

example(of: "Defer Replay Connect") {
  let xs = Observable.deferred { () -> Observable<TimeInterval> in
      print("Performing work ...")
      return Observable.just(Date().timeIntervalSince1970).delay(0.1, scheduler: MainScheduler.instance)
    }.debug("Defer Replay Connect").replay(1)
  
  _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
  _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
  _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
  
  xs.connect().disposed(by: disposeBag)
}

example(of: "Replay RefCount") {
  let observable = Observable<TimeInterval>.create { (observer) -> Disposable in
      print("Create Observable1")
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
        observer.onNext(Date().timeIntervalSince1970)
        observer.onCompleted()
      })
      return Disposables.create()
    }.debug().replay(1).refCount()
  
  observable.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") }).dispose()
  observable.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") }).dispose()
  observable.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") }).dispose()
}

example(of: "No Replay RefCount") {
  let observable =  Observable<TimeInterval>.create { (observer) -> Disposable in
    print("Create Observable2")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
      observer.onNext(Date().timeIntervalSince1970)
      observer.onCompleted()
    })
    return Disposables.create()
  }.debug("Nothing")
  // .replay(1).refCount()
  
  observable.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") }).dispose()
  observable.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") }).dispose()
  observable.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") }).dispose()
}

example(of: "Share") {
  let observable = Observable<TimeInterval>.create { (observer) -> Disposable in
    print("Create Observable3")
    observer.onNext(Date().timeIntervalSince1970)
    observer.onCompleted()
    return Disposables.create()
  }.debug("Share").share(replay: 0, scope: .forever)
  
  observable.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
  observable.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
  observable.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
  
  Observable.just(1).debug("just").subscribe().disposed(by: disposeBag)
  
  Observable<Int>.error(RxError.noElements ).debug("error").subscribe().disposed(by: disposeBag)
  
  Observable.just(1).debug("no dispose bag").subscribe().dispose()
  
  var a: Disposable? = Observable.just(1).delay(0.5, scheduler: SerialDispatchQueueScheduler(qos: .background)).debug("no dispose bag with delpay").subscribe()
  
  a = nil
  
  Observable<Int>.interval(0.5, scheduler: MainScheduler.instance).take(4).debug("interval").subscribe()
  
  observable.debug("no disposeBag with propery").subscribe()
  
  observable.delay(0.5, scheduler: MainScheduler.instance).debug("no disposeBag with propery with delay").subscribe()
}



