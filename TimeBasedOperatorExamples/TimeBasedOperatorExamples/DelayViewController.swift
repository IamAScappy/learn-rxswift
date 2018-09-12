//
//  DelayViewController.swift
//  TimeBasedOperatorExamples
//
//  Created by yuaming on 2018. 9. 12..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// http://rxswift.tbd.ink/RxSwiftStudy/Operator/Time.html
class DelayViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
  }
  
  private func bind() {
    let elementsPerSecond = 1
    let delayInSeconds: RxTimeInterval = 5
    
    let sourceTimeline = TimelineView<Int>.make()
    let delayedTimeline = TimelineView<Int>.make()
    
    let sourceObservable =  Observable<Int>.interval(Double(elementsPerSecond), scheduler: MainScheduler.instance)
    
    let stack = UIStackView.makeVertical([
      UILabel.makeTitle("delay"),
      UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
      sourceTimeline,
      UILabel.make("Delayed elements (with a \(delayInSeconds)s delay):"),
      delayedTimeline
    ])
    
    _ = sourceObservable.subscribe(sourceTimeline)
    
    // DelaySubscription
    // - Item을 받기 시작하는 시점을 지연함(= Subscribe 지연)
//    _ = sourceObservable
//      .delaySubscription(delayInSeconds, scheduler: MainScheduler.instance)
//      .subscribe(delayedTimeline)
    
    // Delay
    // - Item Emit하는 시간을 설정한 시간만큼 미룸(= Subscribe를 지연하는 것이 아니라 방출 시점을 지연함)
    
    // Timer
    // 마감 시간을 설정할 수 있음. 반복 기간은 옵셔널. 만약 반복 기간을 설정하지 않으면 Timer Observable은 한번만 방출하고 완료됨
    _ = Observable<Int>
      .timer(3, scheduler: MainScheduler.instance)
      .flatMap { _ in
        sourceObservable.delay(RxTimeInterval(delayInSeconds), scheduler: MainScheduler.instance)
      }.subscribe(delayedTimeline)
    
//    sourceObservable
//      .delay(RxTimeInterval(delayInSeconds), scheduler: MainScheduler.instance)
//      .subscribe(delayedTimeline)
    
    let hostView = setupHostView()
    hostView.addSubview(stack)
    view.addSubview(hostView)
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.topAnchor.constraint(equalTo: hostView.topAnchor, constant: 100).isActive = true
  }
}
