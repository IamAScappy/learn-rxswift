//
//  SubjectExamples.swift
//  RxSwiftExamples1
//
//  Created by yuaming on 2018. 8. 11..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SubjectExamples {
  private var disposeBag = DisposeBag()
  
  private let itsNotMyFault = "It’s not my fault."
  private let doOrDoNot = "Do. Or do not. There is no try."
  private let lackOfFaith = "I find your lack of faith disturbing."
  private let eyesCanDeceive = "Your eyes can deceive you. Don’t trust them."
  private let stayOnTarget = "Stay on target."
  private let iAmYourFather = "Luke, I am your father"
  private let useTheForce = "Use the Force, Luke."
  private let theForceIsStrong = "The Force is strong with this one."
  private let mayTheForceBeWithYou = "May the Force be with you."
  private let mayThe4thBeWithYou = "May the 4th be with you."
  
  func execute() {
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
    Utils.example(of: "PublishSubject") {
      let quotes = PublishSubject<String>()
      
      quotes.onNext(itsNotMyFault)
      
      let subscriptionOne = quotes.subscribe {
        Utils.print(label: "1)", event: $0)
      }
      
      quotes.on(.next(doOrDoNot))
      
      let subscriptionTwo = quotes.subscribe {
        Utils.print(label: "2)", event: $0)
      }
      
      subscriptionOne.dispose()
      
      quotes.onNext(eyesCanDeceive)
      
      // Subject가 종료한 후, 새로운 Subscriber가 생긴다고 다시 subject가 작동하지 않지만 Completed 이벤트만 방출함
      quotes.onCompleted()
      
      quotes.onNext(lackOfFaith)
      quotes.onNext(mayTheForceBeWithYou)
      
      let subscriptionThree = quotes.subscribe {
        Utils.print(label: "3)", event: $0)
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
    Utils.example(of: "BehaviorSubject") {
      let quotes = BehaviorSubject<String>(value: iAmYourFather)
      
      quotes.subscribe {
        Utils.print(label: "1)", event: $0)
      }
      
      quotes.onNext(itsNotMyFault)
      quotes.onNext(eyesCanDeceive)
      // quotes.onError(Quote.neverSaidThat)
      quotes.onCompleted()
      
      quotes.subscribe {
        Utils.print(label: "2)", event: $0)
      }.disposed(by: disposeBag)
    }
    
    /*
     * ReplaySubject
     
     - 미리 정해진 사이즈 만큼 가장 최근의 이벤트를 새로운 Subscriber에게 전달함
     */
    Utils.example(of: "ReplaySubject") {
      disposeBag = DisposeBag()
      
      let subject = ReplaySubject<String>.create(bufferSize: 2)
      
      subject.onNext(eyesCanDeceive)
      subject.subscribe {
        Utils.print(label: "1)", event: $0)
      }.disposed(by: disposeBag)
      
      subject.onNext(iAmYourFather)
      subject.onNext(itsNotMyFault)
      subject.onNext(mayThe4thBeWithYou)
      
      // 버퍼 사이즈가 2이기 때문에 최근 이벤트 2개를 새로운 구독자에게 전달함
      subject.subscribe {
        Utils.print(label: "2)", event: $0)
      }.disposed(by: disposeBag)
    }
    
    Utils.example(of: "BehaviorRelay") {
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
        Utils.print(label: "1)", event: $0)
      }.disposed(by: disposeBag)
      
      // variable.value = mayThe4thBeWithYou
      // variable.value = MyError.anError
      // variable.asObservable().onError(MyError.anError)
      // variable.asObservable().onCompleted()
      
      // behaviorRelay.value = mayThe4thBeWithYou
    }
  }
}






