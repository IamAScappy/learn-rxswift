//
//  TransformingOperatorExamples.swift
//  RxSwiftExamples1
//
//  Created by yuaming on 2018. 8. 11..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TransformingOperatorExamples: BaseClass {
  func execute() {
    // ToArray
    // - Observable 요소들을 Array에 담아 이벤트를 방출함
    
    // 실행결과
    // ["A", "B", "C"]
    Utils.example(of: "toArray") {
      Observable.of("A", "B", "C")
        .toArray()
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
    }
    
    // Map
    // - 이벤트를 다른 이벤트로 변환함
    // - public func map<R>(_ transform: @escaping (Self.E) throws -> R) -> RxSwift.Observable<R>
    
    // 실행결과
    // String으로 변환: 123
    // String으로 변환: 4
    // String으로 변환: 56
    Utils.example(of: "Map") {
      Observable<Int>.of(123, 4, 56)
        .map { "String으로 변환: \($0)" }
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
    }
    
    // Enumerated
    
    // 실행결과
    // 1
    // 2
    // 3
    // 8
    // 10
    // 12
    Utils.example(of: "Enumerated and Map") {
      Observable.of(1, 2, 3, 4, 5, 6)
        .enumerated()
        .map { index, integer in
          index > 2 ? integer * 2 : integer
        }
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
    }
    
    // FlatMap
    // - 이벤트 시퀀스를 다른 이벤트 시퀀스로 변형함
    // - 한 개의 Observable을 넣고 flatMap을 통해 여러 개 Observable로 변형할 수 있음
    // - 각 Observable를 지속적으로 관찰하다가 변화를 반영함
    // - Map은 nil를 반환할 수 있지만, FlatMap은 그렇지 않음
    // - public func flatMap<O>(_ selector: @escaping (Self.E) throws -> O) -> RxSwift.Observable<O.E> where O : 함
    
    // 실행결과
    // 80
    // 85
    // 90
    // 95
    // 99
    // 100
    Utils.example(of: "FlatMap") {
      let ryan = Student(score: BehaviorSubject(value: 80))
      let charlotte = Student(score: BehaviorSubject(value: 90))
      let student = PublishSubject<Student>()
      
      student
        .flatMap { $0.score }
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)

      student.onNext(ryan)
      ryan.score.onNext(85)
      student.onNext(charlotte)
      ryan.score.onNext(95)
      ryan.score.onNext(99)
      charlotte.score.onNext(100)
    }
    
    // FlatMapLatest
    // - 새로운 이벤트가 들어오면 앞에 생성된 Observable를 무시함. 자동완성 검색할 때 사용할 수 있음
    // - Map + SwitchLatest
    
    // 실행결과
    // 80
    // 85
    // 90
    // 100
    Utils.example(of: "FlatMapLatest") {
      let ryan = Student(score: BehaviorSubject(value: 80))
      let charlotte = Student(score: BehaviorSubject(value: 90))
      let student = PublishSubject<Student>()
      
      student
        .flatMapLatest { $0.score }
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
      
      student.onNext(ryan)
      ryan.score.onNext(85)
      
      // charlotte의 Next 이벤트가 발생함. 그래서 ryan에서 발생하는 Next 이벤트들은 이 시점으로 구독해지됨
      student.onNext(charlotte)
      ryan.score.onNext(95)
      ryan.score.onNext(99)
      charlotte.score.onNext(100)
    }
    
    // FlatMapFirst
    // - 먼저 생성된 Observable이 끝나기 전까지 들어오는 이벤트는 무시함. 첫 번째 생성한 이벤트가 끝까지 일어남
    
    // 실행결과
    // 80
    // 85
    // 95
    // 99
    Utils.example(of: "FlatMapFirst") {
      let ryan = Student(score: BehaviorSubject(value: 80))
      let charlotte = Student(score: BehaviorSubject(value: 90))
      let student = PublishSubject<Student>()
      
      student
        .flatMapFirst { $0.score }
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
      
      // ryan에서 첫 번재 이벤트가 발생함. 그래서 charlotte에서 발생하는 Next 이벤트들은 무시함
      student.onNext(ryan)
      ryan.score.onNext(85)
    
      student.onNext(charlotte)
      ryan.score.onNext(95)
      ryan.score.onNext(99)
      
      charlotte.score.onNext(100)
    }
    
    // Materialize
    // - 이벤트의 Observable을 만듦. 그래서 Error도 error(...) 형태로 출력함
    // Dematerialize
    // - 원래대로 돌아감
    
    // 실행결과
    // next(80)
    // 80
    // next(85)
    // 85
    // error(anError)
    // anError
    // next(100)
    // 100
    Utils.example(of: "Materialize and Dematerialize") {
      enum MyError: Error {
        case anError
      }
      
      let ryan = Student(score: BehaviorSubject(value: 80))
      let charlotte = Student(score: BehaviorSubject(value: 100))
      let student = BehaviorSubject(value: ryan)
      let studentScore = student.flatMapLatest { $0.score.materialize() }
      
      studentScore
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
      
      studentScore.filter {
          guard $0.error == nil else {
            print($0.error!)
            return false
          }
        
          return true
        }
        .dematerialize()
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
      
      ryan.score.onNext(85)
      ryan.score.onError(MyError.anError)
      ryan.score.onNext(90)
      student.onNext(charlotte)
    }
  }
}

extension TransformingOperatorExamples {
  struct Student {
    var score: BehaviorSubject<Int>
  }
}
