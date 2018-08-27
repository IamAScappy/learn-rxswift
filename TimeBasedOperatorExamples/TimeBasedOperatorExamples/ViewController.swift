//
//  ViewController.swift
//  TimeBasedOperatorExamples
//
//  Created by yuaming on 2018. 8. 27..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    buffer()
    delay()
    replay()
    timeout()
    window()
  }
  
  private func buffer() {
    let bufferTimeSpan: RxTimeInterval = 4
    let bufferMaxCount = 2
    
    let sourceObservable = PublishSubject<String>()
    
    let sourceTimeline = TimelineView<String>.make()
    let bufferedTimeline = TimelineView<Int>.make()
    
    let stack = UIStackView.makeVertical([
      UILabel.makeTitle("buffer"),
      UILabel.make("Emitted elements:"),
      sourceTimeline,
      UILabel.make("Buffered elements (at most \(bufferMaxCount) every \(bufferTimeSpan) seconds):"),
      bufferedTimeline])
    
    _ = sourceObservable.subscribe(sourceTimeline)
    
    sourceObservable
      .buffer(timeSpan: bufferTimeSpan, count: bufferMaxCount, scheduler: MainScheduler.instance)
      .map { $0.count }
      .subscribe(bufferedTimeline)
    
    let hostView = setupHostView()
    hostView.addSubview(stack)
    view.addSubview(hostView)
    
    let elementsPerSecond = 0.7
    let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
      sourceObservable.onNext("🐱")
    }
  }
  
  private func delay() {
    let elementsPerSecond = 1
    let delayInSeconds = 1.5
    
    let sourceObservable = PublishSubject<Int>()
    
    let sourceTimeline = TimelineView<Int>.make()
    let delayedTimeline = TimelineView<Int>.make()
    
    let stack = UIStackView.makeVertical([
      UILabel.makeTitle("delay"),
      UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
      sourceTimeline,
      UILabel.make("Delayed elements (with a \(delayInSeconds)s delay):"),
      delayedTimeline
    ])
    
    var current = 1
    let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
      sourceObservable.onNext(current)
      current = current + 1
    }
    
    _ = sourceObservable.subscribe(sourceTimeline)
    
    _ = Observable<Int>
      .timer(3, scheduler: MainScheduler.instance)
      .flatMap { _ in
        sourceObservable.delay(RxTimeInterval(delayInSeconds), scheduler: MainScheduler.instance)
      }.subscribe(delayedTimeline)
    
    
    let hostView = setupHostView()
    hostView.addSubview(stack)
    view.addSubview(hostView)
  }
  
  private func replay() {
    let elementsPerSecond = 1
    let replayedElements = 1
    let replayDelay: TimeInterval = 3
    
    let sourceObservable = Observable<Int>
      .interval(RxTimeInterval(1.0 / Double(elementsPerSecond)), scheduler: MainScheduler.instance)
      .replay(replayedElements)
    
    let sourceTimeline = TimelineView<Int>.make()
    let replayedTimeline = TimelineView<Int>.make()
    
    let stack = UIStackView.makeVertical([
      UILabel.makeTitle("replay"),
      UILabel.make("Emit \(elementsPerSecond) per second:"), sourceTimeline,
      UILabel.make("Replay \(replayedElements) after \(replayDelay) sec:"),
      replayedTimeline
    ])
    
    _ = sourceObservable.subscribe(sourceTimeline)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
      _ = sourceObservable.subscribe(replayedTimeline)
    }
    
    _ = sourceObservable.connect()
    
    let hostView = setupHostView()
    hostView.addSubview(stack)
    view.addSubview(hostView)
  }
  
  private func timeout() {
    let button = UIButton(type: .system)
    button.setTitle("Press me now!", for: .normal)
    button.sizeToFit()
    
    let tapsTimeline = TimelineView<String>.make()
    
    let stack = UIStackView.makeVertical([
      button,
      UILabel.make("Taps on button above"),
      tapsTimeline])
    
    let _ = button
      .rx.tap
      .map { _ in "•" }
      .timeout(5, other: Observable.just("X"), scheduler: MainScheduler.instance)
      .subscribe(tapsTimeline)
    
    let hostView = setupHostView()
    hostView.addSubview(stack)
    view.addSubview(hostView)
  }
  
  private func window() {
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
    
    let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
      sourceObservable.onNext("🐱")
    }
    
    _ = sourceObservable.subscribe(sourceTimeline)
    
    _ = sourceObservable
      .window(timeSpan: windowTimeSpan, count: windowMaxCount, scheduler: MainScheduler.instance)
      .flatMap { windowedObservable -> Observable<(TimelineView<Int>, String?)> in
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
  }
}

fileprivate extension ViewController {
  func setupHostView() -> UIView {
    let hostView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 640))
    hostView.backgroundColor = .white
    return hostView
  }
}
