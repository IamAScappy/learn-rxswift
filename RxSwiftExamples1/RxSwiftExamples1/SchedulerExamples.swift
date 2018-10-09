//
//  SchedulerExamples.swift
//  RxSwiftExamples1
//
//  Created by yuaming on 09/10/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import Foundation
import RxSwift

class SchedulerExamples: BaseClass {
  func execute() {
    print("\n\n\n===== Schedulers =====\n")
    
    let globalScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
    let bag = DisposeBag()
    let animal = BehaviorSubject(value: "[dog]")

    animal
      .subscribeOn(MainScheduler.instance)
      .dump()
      .observeOn(globalScheduler)
      .dumpingSubscription()
      .disposed(by: bag)

    let fruit = Observable<String>.create { observer in
      observer.onNext("[apple]")
      sleep(2)
      observer.onNext("[pineapple]")
      sleep(2)
      observer.onNext("[strawberry]")
      return Disposables.create()
    }
    
    /*
     스케줄러와 GCD 대기열은 유사하게 동작할 수 있지만, 같지 않음. 커스텀 스케줄러를 사용할 경우 같은 스레드에서 여러 스케줄에서 동작할 수 있고, 하나 스케줄에서 여러 스레드가 동작할 수 있음
     
     subscribeOn => Observable의 작업을 시작하는 쓰레드를 선택할 수 있음. 여러 번 적게되면, 마지막 것을 적용함
     
     observeOn => observeOn은 이후 나오는 오퍼레이터, subscribe의 스케쥴러를 변경할 수 있음
     
     일반적인 패턴: Background Process를 사용하여 서버에서 데이터를 검색하고 수신된 데이터를 처리하고MainScheduler로 전환하여 최종 이벤트를 처리하고 사용자 인터페이스에 데이터를 표시함
    */
//    fruit
//      .subscribeOn(globalScheduler)
//      .dump()
//      .observeOn(MainScheduler.instance)
//      .dumpingSubscription()
//      .disposed(by: bag)
    
    let animalsThread = Thread() {
      sleep(3)
      animal.onNext("[cat]")
      sleep(3)
      animal.onNext("[tiger]")
      sleep(3)
      animal.onNext("[fox]")
      sleep(3)
      animal.onNext("[leopard]")
    }

    animalsThread.name = "Animals Thread"
    animalsThread.start()

    /*
     ===== Schedulers =====
     
     00s | [D] [dog] received on Main Thread
     00s | [S] [dog] received on Anonymous Thread
     03s | [D] [cat] received on Animals Thread
     03s | [S] [cat] received on Anonymous Thread
     06s | [D] [tiger] received on Animals Thread
     06s | [S] [tiger] received on Anonymous Thread
     09s | [D] [fox] received on Animals Thread
     09s | [S] [fox] received on Anonymous Thread
     12s | [D] [leopard] received on Animals Thread
     12s | [S] [leopard] received on Anonymous Thread
     
     Q. .subscribeOn(MainScheduler.instance) 추가하기 전이나 추가한 뒤에도 subscribeOn이 적용되지 않고 같은 결과가 나오는 이유?
     
     A. animal에 Push가 일어나고 있지만, Push 처리하는 곳은 AnimalsThread이기 때문에 다른 스레드로 이동할 수 없음. 결론은 Thread와 스케줄러는 별개로 동작한다고 생각하면 편함
    */
    animal
      .subscribeOn(MainScheduler.instance)
      .dump()
      .observeOn(globalScheduler)
      .dumpingSubscription()
      .disposed(by:bag)
    
//    fruit
//      .subscribeOn(globalScheduler)
//      .dump()
//      .observeOn(MainScheduler.instance)
//      .dumpingSubscription()
//      .disposed(by:bag)
    
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 13))
    
    /*
     Serial, Concurrent 스케줄러
     
     - Rx는 순차적으로 처리하고 Serial 스케줄러는 Serial Dispatch Queue를 이용해 최적화 시킬 수 있음
     - Concurrent 스케줄러는 Rx를 동시에 실행하려고 하지만, observeOn과 subscribeOn이 실행되어야 하는 Sequence는 유지하여 subscribe 코드가 실행되는 스케줄러가 바르게 동작해야 함
     
     MainScheduler
     
     - Main Thread 위에서 동작하며 UI 업데이트할 때 사용함. 그리고, Driver는 MainScheduler에서 항상 동작하면서 UI에서 데이터를 직접 바인딩할 수 있도록 함
     
     SerialDispatchQueueScheduler
     - Serial Dispatch Queue의 작업을 추상화 함. observeOn을 사용할 때 최적화가 잘 됨
     - Serial 작업뿐만 아니라 Background에서 도는 작업도 적합함
     
     ConcurrentDispatchQueueScheduler
     - SerialDispatchQueueScheduler와 비슷하게 Dispatch Queue의 작업을 추상화 함. Serial Queue 대신 Concurrent Queue를 사용한다는 것이 다른 점
     - 이러한 종류 스케줄러는 observeOn 최적화가 잘되어 있지 않기 때문에 잘 선택해야 함
     
     OperationQueueScheduler
     - 장기적으로 여러 작업을 처리해야 할 때 적합한 스케줄러. 여러 개 동시 작업하고 결과를 수집하는데 최적화할 수 있음
     
     TestScheduler
     - 프로덕션 레벨에서 사용하면 안 됨. RxTest 라이브러리 일부
    */
  }
}

let start = Date()

fileprivate func getThreadName() -> String {
  if Thread.current.isMainThread {
    return "Main Thread"
  } else if let name = Thread.current.name {
    if name == "" {
      return "Anonymous Thread"
    }
    return name
  } else {
    return "Unknown Thread"
  }
}

fileprivate func secondsElapsed() -> String {
  return String(format: "%02i", Int(Date().timeIntervalSince(start).rounded()))
}

extension ObservableType {
  func dump() -> RxSwift.Observable<Self.E> {
    return self.do(onNext: { element in
      let threadName = getThreadName()
      print("\(secondsElapsed())s | [D] \(element) received on \(threadName)")
    })
  }
  
  func dumpingSubscription() -> Disposable {
    return self.subscribe(onNext: { element in
      let threadName = getThreadName()
      print("\(secondsElapsed())s | [S] \(element) received on \(threadName)")
    })
  }
}
