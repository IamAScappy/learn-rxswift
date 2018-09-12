//
//  ObservableExamples.swift
//  RxSwiftExamples1
//
//  Created by yuaming on 2018. 8. 11..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ObservableExamples: BaseClass {
  private let woong = "Woong"
  private let gamja = "Gamja"
  private let sj = "SJ"
  private let hj = "HJ"
  
  func execute() {
    /*
     * Observable
     
     1. just
     - Observable의 타입 메서드. Observable Sequence를 만듦
     
     2. of
     - 컴파일러가 타입을 추론하여 Observable Sequence를 만듦
     
     3. from
     - Observable<String>. Array 요소를 하나씩 배출함. Array 인자만 가짐
     */
    Utils.example(of: "Create observable") {
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
     
     * 실행결과
     Woong
     Gamja
     SJ
     */
    Utils.example(of: "Subscribe") {
      Observable.of(woong, gamja, sj).subscribe(onNext: { element in
        print(element)
      })
    }
    
    /*
     * Empty
     
     - Completed만 방출함
     - 의도적으로 아무런 타입이 아닌 Observable를 반환할 때 사용함
     
     * 실행결과
     Completed
     */
    Utils.example(of: "Empty") {
      Observable<Void>.empty().subscribe(onNext: { element in
        print(element)
      }, onCompleted: {
        print("Completed")
      })
    }
    
    
    Utils.example(of: "Never") {
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
     
     * 실행결과
     next(Woong)
     next(Gamja)
     next(SJ)
     completed
     */
    Utils.example(of: "Dispose") {
      Observable.of(woong, gamja, sj).subscribe { event in

        print(event)
      }.dispose()
    }
    
    /*
     * 실행결과
     next(Woong)
     next(Gamja)
     next(SJ)
     completed
    */
    Utils.example(of: "DisposeBag") {
      Observable.of(woong, gamja, sj).subscribe {
        print($0)
      }.disposed(by: disposeBag)
    }
    
    
    /*
     * Create
     
     - Create를 이용하여 Observable를 만들 수 있음
     - onError 이벤트가 발생하면 Dispose 되는 것을 확인할 수 있음. 즉 메모리가 해제된다는 것을 알 수 있음
     - 만약, Error, Complete도 발생하지 않고 Dispose도 없다면 컴파일러가 메모리 릭이 발생하는 것을 경고함
     
     * 결과
     R2-D2
     Error: OU812
     Disposed
     */
    Utils.example(of: "Create") {
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
     
     * 실행결과
     Do: About to subscribe
     Subscribe: Completed
     Subscribe: Disposed
     Do: Disposed
     */
    Utils.example(of: "Do") {
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
     
     * 실행결과
     fileNotFound
     */
    Utils.example(of: "Single") {
      loadText(from: "ANewHope").subscribe {
        switch $0 {
        case .success(let string):
          print(string)
        case .error(let error):
          print(error)
        }
      }.disposed(by: disposeBag)
    }
  }
}

extension ObservableExamples {
  fileprivate enum FileReadError: Error {
    case fileNotFound, unreadable, encodingFailed
  }
  
  fileprivate enum Quote: Error {
    case neverSaidThat
  }
  
  fileprivate enum MyError: Error {
    case anError
  }
  
  fileprivate enum Droid: Error {
    case OU812
  }
  
  fileprivate func loadText(from filename: String) -> Single<String> {
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
}
