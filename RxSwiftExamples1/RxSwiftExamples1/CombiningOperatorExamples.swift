//
//  CombiningOperatorExamples.swift
//  RxSwiftExamples1
//
//  Created by yuaming on 2018. 8. 13..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CombiningOperatorExamples: BaseClass {
  func execute() {
    // Appending
    // StartWith
    // - Observer에서 초기값 받는 여부가 중요함
    // - Observable에 무슨 일이 일어나더라도 초기값이 붙는 것을 보장함
    
    // 실행결과
    // 1
    // 2
    // 3
    // 4
    Utils.example(of: "StartWith") {
      let numbers = Observable.of(2, 3, 4)
      
      let observable = numbers.startWith(1)
      observable.subscribe(onNext: { value in
        print(value)
      }).disposed(by: disposeBag)
    }
    
    // Observable.Concat
    // - Observable Sequence끼리 연결함
    // - 내부에서 에러가 나면 Concat 되어 있는 Observable에서 에러가 발생하여 종료함
    
    // 실행결과
    // 1
    // 2
    // 3
    // 4
    // 5
    // 6
    // 7
    // 8
    // 9
    Utils.example(of: "Observable.Concat") {
      let first = Observable.of(1, 2, 3)
      let second = Observable.of(4, 5, 6)
      let third = Observable.of(7, 8, 9)
      let observable = Observable.concat([first, second, third])
      
      observable.subscribe(onNext: { value in
        print(value)
      }).disposed(by: disposeBag)
    }
    
    // Concat
    // - Observable.Concat 과 비슷함. 결합할 때 두 개의 Observable이 반드시 타입이 같아야 함
    
    // 실행결과
    // Berlin
    // Münich
    // Frankfurt
    // Madrid
    // Barcelona
    // Valencia
    Utils.example(of: "Concat") {
      let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
      let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")
      
      let observable = germanCities.concat(spanishCities)
      
      observable.subscribe(onNext: { value in
        print(value)
      }).disposed(by: disposeBag)
    }
    
    // ConcatMap
    // - Subscribe 되기 전, 각각 Observable Sequence가 Concat이 된다는 것을 보장함
    // - FlatMap가 비슷함
    
    // 실행결과
    // Berlin
    // Münich
    // Frankfurt
    // 서울
    // 부산
    // 대구
    Utils.example(of: "ConcatMap") {
      let sequences = [
        "Germany": Observable.of("Berlin", "Münich", "Frankfurt"),
        "Spain": Observable.of("Madrid", "Barcelona", "Valencia"),
        "Korea": Observable.of("서울", "부산", "대구")
      ]
      
      let observable = Observable.of("Germany", "Spain2", "Korea")
      // let observable = Observable.of("Germany", "Spain", "Korea")
        .concatMap { country in sequences[country] ?? .empty() }
      
      observable.subscribe(onNext: { string in
        print(string)
      }).disposed(by: disposeBag)
    }
    
    
    // 합치기
    // Merge
    // - 결과를 돌려보면 규칙이 정해져 있지 않음. Observable가 도착하는대로 이벤트를 방출함
    // - 어떠한 Sequence라도 에러를 방출하면 Merge도 에러를 방출하고 이벤트를 종료함
    
    // 실행결과
    // Right :Madrid
    // Left: Berlin
    // Right :Barcelona
    // Left: Münich
    // Right :Valencia
    // Left: Frankfurt
    Utils.example(of: "Merge") {
      let left = PublishSubject<String>()
      let right = PublishSubject<String>()
      
      let source = Observable.of(left.asObservable(), right.asObservable())
      
      let observable = source.merge()
      let disposable = observable.subscribe(onNext: {
        print($0)
      })
      
      var leftValues = ["Berlin", "Münich", "Frankfurt"]
      var rightValues = ["Madrid", "Barcelona", "Valencia"]
      
      repeat {
        if arc4random_uniform(2) == 0 {
          if !leftValues.isEmpty {
            left.onNext("Left: " + leftValues.removeFirst())
          }
        } else if !rightValues.isEmpty {
          right.onNext("Right :" + rightValues.removeFirst())
        }
      } while !leftValues.isEmpty || !rightValues.isEmpty
      
      disposable.dispose()
    }
    
    
    // 결합
    // CombineLatest
    // - Observable 객체들에게서 이벤트가 발생할 때마다 가장 최근에 발생한 이벤트를 합침
    // - 결합한 Observable가 하나의 값이 방출하기 전까지 아무 일이 일어나지 않음. 이벤트가 방출하고 나면 클로저 타입의 Observable가 생성됨
    // - Map처럼 클로저 타입으로 Observable가 생성되기 때문에 새로운 유형으로 전환하기 좋음
    // - CombineLatest는 Sequence 타입이 달라도 됨
    
    // 실행결과
    // > Sending a value to Left
    // > Sending a value to Right
    // Hello, world
    // > Sending another value to Right
    // Hello, RxSwift
    // > Sending another value to Left
    // Have a good day, RxSwift
    Utils.example(of: "CombineLast") {
      let left = PublishSubject<String>()
      let right = PublishSubject<String>()
      
      let observable = Observable.combineLatest(left, right, resultSelector: { lastLeft, lastRight in
        "\(lastLeft) \(lastRight)"
      })
      
      let disposable = observable.subscribe(onNext: {
        print($0)
      })
    
      print("> Sending a value to Left")
      left.onNext("Hello,")
      print("> Sending a value to Right")
      right.onNext("world")
      print("> Sending another value to Right")
      right.onNext("RxSwift")
      print("> Sending another value to Left")
      left.onNext("Have a good day,")
      
      disposable.dispose()
    }
    
    // 실행결과
    // 12/09/2018
    // 12 September 2018
    Utils.example(of: "Combine user choice and value") {
      let choice: Observable<DateFormatter.Style> = Observable.of(.short, .long)
      let dates: Observable<Date> = Observable.of(Date())
      
      let observable = Observable.combineLatest(choice, dates, resultSelector: { (format, when) -> String in
        let formatter = DateFormatter()
        formatter.dateStyle = format
        return formatter.string(from: when)
      })
      
      observable.subscribe(onNext: {
        print($0)
      }).disposed(by: disposeBag)
    }
    
    // Array로도 결합 가능함
    
    // 실행결과
    // > Sending a value to Left
    // > Sending a value to Right
    // Hello - world
    // > Sending another value to Right
    // Hello - RxSwift
    // > Sending another value to Left
    // Have a good day - RxSwift
    Utils.example(of: "CombineLatest Array") {
      let left = PublishSubject<String>()
      let right = PublishSubject<String>()
      
      let observable = Observable.combineLatest([left, right]) { strings in
        strings.joined(separator: " - ")
      }
      
      let disposable = observable.subscribe(onNext: {
        print($0)
      })
      
      print("> Sending a value to Left")
      left.onNext("Hello")
      print("> Sending a value to Right")
      right.onNext("world")
      print("> Sending another value to Right")
      right.onNext("RxSwift")
      print("> Sending another value to Left")
      left.onNext("Have a good day")
      
      disposable.dispose()
    }
    
    
    // Zip
    // - Observable이 새 값이 각각 방출되기 기다리다가 둘 중 하나 Observable가 완료되면 Zip도 완료함
    // - 이벤트 요소가 남아있어도 Zip은 기다려주지 않음
    // - Indexed Sequencing
    
    // 실행결과
    // It's sunny in Lisbon
    // It's cloudy in Copenhagen
    // It's cloudy in London
    // It's sunny in Madrid
    Utils.example(of: "Zip") {
      enum Weatehr {
        case cloudy
        case sunny
      }
      
      let left: Observable<Weatehr> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
      let right: Observable<String> = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")
      
      let observable = Observable.zip(left, right, resultSelector: { (weather, city) in
        return "It's \(weather) in \(city)"
      })
      
      observable.subscribe(onNext: {
        print($0)
      }).disposed(by: disposeBag)
    }
    
    
    // Trigger
    // WithLatestFrom
    // - 두 개 Observable을 합성하지만, 한 쪽에서 이벤트가 발생할 때 합성함. 만약 이벤트가 일어나지 않는다면 Skip됨
    // - textField에서 이벤트가 계속 일어나더라도 button에서 반응이 없다면 이벤트가 Skip되지만 button에서 이벤트가 일어나는 순간 textField 이벤트와 합성이 됨
    
    // 실행결과
    // P
    // P
    Utils.example(of: "WithLatestFrom") {
      let button = PublishSubject<Void>()
      let textField = PublishSubject<String>()
      
      let observable = button.withLatestFrom(textField)
      _ = observable.subscribe(onNext: { print($0) })
      
      textField.onNext("Par")
      textField.onNext("Pari")
      textField.onNext("Paris")
      textField.onNext("P")
      button.onNext(())
      button.onNext(())
    }
    
    
    // Switching
    // Amb
    // - 처음 발생한 Observable만 사용함
    
    // 실행결과
    // Copenhagen
    // Vienna
    Utils.example(of: "Amb") {
      let left = PublishSubject<String>()
      let right = PublishSubject<String>()
      
      let observable = right.amb(left)
      let disposable = observable.subscribe(onNext: { value in
        print(value)
      })
      
      right.onNext("Copenhagen")
      left.onNext("Lisbon")
      left.onNext("London")
      left.onNext("Madrid")
      right.onNext("Vienna")
      
      disposable.dispose()
    }
    
    // SwitchLatest
    // - Observable가 바뀌면 해당 Observable가 실행되는 것을 확인할 수 있음
    
    // 실행결과
    // Some text from sequence one
    // More text from sequence two
    // Hey it's three. I win :3
    // Hey it's three. I win
    Utils.example(of: "SwitchLatest") {
      let one = PublishSubject<String>()
      let two = PublishSubject<String>()
      let three = PublishSubject<String>()
      
      let source = PublishSubject<Observable<String>>()
      
      let observable = source.switchLatest()
      let disposable = observable.subscribe(onNext: { print($0) })
      
      source.onNext(one)
      one.onNext("Some text from sequence one")
      two.onNext("Some text from sequence two")
      
      source.onNext(two)
      two.onNext("More text from sequence two")
      one.onNext("and also from sequence one")
      
      source.onNext(three)
      two.onNext("Why don't you see me?")
      one.onNext("I'm alone, help me")
      three.onNext("Hey it's three. I win :3")
      
//      source.onNext(one)
//      one.onNext("Nope. It's me, one!")
      two.onNext("Nope. It's me, two!!")
      three.onNext("Hey it's three. I win")
      
      disposable.dispose()
    }
    
    
    
    // Reduce
    // - 기본값으로 방출한 이벤트 값을 연산하여 하나의 값으로 나옴
    // - public func reduce<A>(_ seed: A, accumulator: @escaping (A, Self.E) throws -> A) -> RxSwift.Observable<A>
    // - public func reduce<A, R>(_ seed: A, accumulator: @escaping (A, Self.E) throws -> A, mapResult: @escaping (A) throws -> R) -> RxSwift.Observable<R>
    
    // 실행결과
    // 25
    Utils.example(of: "Reduce") {
      let source = Observable.of(1, 3, 5, 7, 9)
      
      let observable = source.reduce(0, accumulator: +)
      observable.subscribe(onNext: { value in
        print(value)
      }).disposed(by: disposeBag)
    }
    
    // Scan
    // - Scan은 Observable의 값이 변경없이 가질 수 있음. 이것을 통해 이벤트를 변형할 수 있음
    // - 총합, 통계, 상태 등 여러 곳에서 사용할 수 있음
    // - 들어오는 이벤트 타입과 변형하려는 타입이 같아야 함
    // - public func scan<A>(_ seed: A, accumulator: @escaping (A, Self.E) throws -> A) -> RxSwift.Observable<A>
    
    // 실행결과
    // 1
    // 4
    // 9
    // 16
    // 25
    Utils.example(of: "Scan") {
      let source = Observable.of(1, 3, 5, 7, 9)
      
      let observable = source.scan(0, accumulator: +)
      observable.subscribe(onNext: {
        print($0)
      }).disposed(by: disposeBag)
    }
  }
}
