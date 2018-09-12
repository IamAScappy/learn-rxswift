//
//  WindowViewController.swift
//  TimeBasedOperatorExamples
//
//  Created by yuaming on 2018. 9. 12..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WindowViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
  }
  
  private func bind() {
    let elementsPerSecond = 3
    let windowTimeSpan: RxTimeInterval = 4
    let windowMaxCount = 10
    let sourceObservable = PublishSubject<String>()
    
    let sourceTimeline = TimelineView<String>.make()
    
    let stack = UIStackView.makeVertical([
      UILabel.makeTitle("window"),
      UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
      sourceTimeline,
      UILabel.make("Windowed observables (at most \(windowMaxCount) every \(windowTimeSpan) sec):")])
        
    _ = sourceObservable.subscribe(sourceTimeline)
    
    // Buffer와 비슷하지만, 다른 점은 새로운 Observable을 만듦
    _ = sourceObservable
      .window(timeSpan: windowTimeSpan, count: windowMaxCount, scheduler: MainScheduler.instance)
      .flatMap { windowedObservable -> Observable<(TimelineView<Int>, String?)> in
        // 새로운 Observable이 생길 때마다 새로운 View가 추가되는 로직을 확인할 수 있음
        let timeline = TimelineView<Int>.make()
        stack.insert(timeline, at: 4)
        stack.keep(atMost: 8)
        return windowedObservable
          .map { value in (timeline, value) }
          .concat(Observable.just((timeline, nil)))
      }.subscribe(onNext: { tuple in
        let (timeline, value) = tuple
        if let value = value {
          timeline.add(.Next(value))
        } else {
          timeline.add(.Completed(true))
        }
      })
    
    let hostView = setupHostView()
    hostView.addSubview(stack)
    view.addSubview(hostView)
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.topAnchor.constraint(equalTo: hostView.topAnchor, constant: 100).isActive = true
  }
}
