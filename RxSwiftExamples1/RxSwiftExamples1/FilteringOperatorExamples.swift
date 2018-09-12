//
//  FilteringOperatorExamples.swift
//  RxSwiftExamples1
//
//  Created by yuaming on 2018. 8. 11..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class FilteringOperatorExamples: BaseClass {
  func execute() {
    // IgonreElements
    // - Next 이벤트는 무시하지만, Completed, Error 이벤트에서 종료함. 그래서 Observable가 종료되었음을 알릴 때 사용하면 좋음
    
    // 실행결과
    // You're out!
    Utils.example(of: "IgonreElements") {
      let strikes = PublishSubject<String>()
      
      strikes
        .ignoreElements()
        .subscribe { _ in
          print("You're out!")
        }
        .disposed(by: disposeBag)
      
      strikes.onNext("A")
      strikes.onNext("B")
      strikes.onNext("C")
      
      strikes.onCompleted()
    }
    
    // ElementAt
    // - 인덱스 N번째 요소 이벤트를 처리하려고 할 때 사용할 수 있음. 그래서 아래 같은 결과에서 인덱스 2번째 이벤트를 한번 더 방출함
    
    // 실행결과
    // You're out!
    // You're out!
    Utils.example(of: "ElementAt") {
      let strikes = PublishSubject<String>()
      
      strikes
        .elementAt(2)
        .subscribe { _ in
          print("You're out!")
        }
        .disposed(by: disposeBag)
      
      strikes.onNext("A")
      strikes.onNext("B")
      strikes.onNext("C")
      
      strikes.onCompleted()
    }
    
    // Filter
    // - Swift 고차함수인 Filter와 기능이 유사함. 모든 요소에 대해 조건을 확인하고 Filter 조건에 맞는 이벤트만 방출함
    
    // 실행결과
    // 2
    // 4
    // 6
    Utils.example(of: "Filter") {
      Observable.of(1, 2, 3, 4, 5, 6)
        .filter { integer in
          integer % 2 == 0
        }
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
    }
    
    // Skip
    // - N 번째 인덱스까지 Skip한 후, 나머지 이벤트를 방출함
    
    // 실행결과
    // D
    // E
    // F
    Utils.example(of: "Skip") {
      Observable.of("A", "B", "C", "D", "E", "F")
        .skip(3)
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
    }
    
    // SkipWhile
    // - Skip할 로직을 구성하고 해당 로직이 false 된 이후, 이벤트를 방출함
    
    // 실행결과
    // 3
    // 4
    // 4
    Utils.example(of: "skipWhile") {
      Observable.of(2, 2, 3, 4, 4)
        .skipWhile { integer in
          integer % 2 == 0
        }
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
    }
    
    // SkipUntil
    // - 다른 Observable이 이벤트를 방출하기 전까지 현재 Observable에서 방출하는 이벤트를 Skip함
    
    // 실행결과
    // C
    Utils.example(of: "SkipUntil") {
      let subject = PublishSubject<String>()
      let trigger = PublishSubject<String>()
      
      subject
        .skipUntil(trigger)
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
      
      subject.onNext("A")
      subject.onNext("B")
      
      trigger.onNext("X")
      
      subject.onNext("C")
    }
    
    // 실행결과
    // 1
    // 2
    // 3
    Utils.example(of: "Take") {
      Observable.of(1, 2, 3, 4, 5, 6)
        .take(3)
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
    }
    
    // TakeWhile
    // - SkipWhile가 반대로 true가 된 이전까지 이벤트를 방출함
    
    // 실행결과
    // 2
    Utils.example(of: "TakeWhile") {
      Observable.of(2, 3, 4, 4, 6, 6)
        .enumerated()
        .takeWhile { index, integer in
          integer % 2 == 0 && index < 3
        }
        .map { $0.element }
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
    }
    
    // TakeUntil
    // - 다른 Observable이 이벤트를 방출하기 전까지 현재 Observable에서 이벤트를 방출함. SkipUntil와 반대임
    
    // 실행결과
    // 1
    // 2
    Utils.example(of: "TakeUntil") {
      let subject = PublishSubject<String>()
      let trigger = PublishSubject<String>()
      
      subject
        .takeUntil(trigger)
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
      
      subject.onNext("1")
      subject.onNext("2")
      
      trigger.onNext("X")
      subject.onNext("3")
    }
    
    // DistinctUntilChanged
    // - 함수 이름 그대로 Distinct. 연달아 나오는 값이 중복될 경우, 중복을 막아줌
    
    // 실행결과
    // A
    // B
    // A
    Utils.example(of: "DistinctUntilChanged") {
      Observable.of("A", "A", "B", "B", "A")
        .distinctUntilChanged()
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
    }
    
    // distinctUntilChanged(_:)
    // - distinctUntilChanged 같음. 그러나 distinctUntilChanged를 커스텀하게 사용할 수 있음
    
    // 실행결과
    // 10
    // 20
    // 200
    Utils.example(of: "distinctUntilChanged(_:)") {
      let formatter = NumberFormatter()
      formatter.numberStyle = .spellOut
      
      Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
        .distinctUntilChanged { a, b in
          // 10 => ten
          // 110 => one hundred ten
          guard let aWords = formatter.string(from: a)?.components(separatedBy: " "),
            let bWords = formatter.string(from: b)?.components(separatedBy: " ")
            else {
              return false
          }
          
          var containsMatch = false
          
          for aWord in aWords {
            for bWord in bWords {
              // aWord: ten, bWord: ten 같은 것이 있을 때 true로 바뀌면서 조건이 맞아 출력됨
              if aWord == bWord {
                containsMatch = true
                break
              }
            }
          }
          
          return containsMatch
        }
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
    }
  }
}
