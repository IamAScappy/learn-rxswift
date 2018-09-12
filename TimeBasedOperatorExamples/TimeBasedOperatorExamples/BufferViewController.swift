//
//  BufferViewController.swift
//  TimeBasedOperatorExamples
//
//  Created by yuaming on 2018. 9. 12..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BufferViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
  }
  
  private func bind() {
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
    
    // Array들은 많아야 bufferMaxCount만큼 요소를 가질 수 있음
    // 만약 bufferTimeSpan이 만료되기 전 이 요소들을 받는다면 buffer 연산자는 버퍼 요소를 방출하고 타이머를 초기화함
    // 마지막 그룹 방출 이후 bufferTimeSpan 지연된다면 buffer는 Array 한 개를 방출함
    // 만약 지연되는 시간동안 받을 요소가 없다면 Array를 빔
    sourceObservable
      .buffer(timeSpan: bufferTimeSpan, count: bufferMaxCount, scheduler: MainScheduler.instance)
      .map { $0.count }
      .subscribe(bufferedTimeline)
    
    // 시각화에서 숫자 0은 0개 요소가 방출된다는 의미임
    let hostView = setupHostView()
    hostView.addSubview(stack)
    view.addSubview(hostView)
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.topAnchor.constraint(equalTo: hostView.topAnchor, constant: 100).isActive = true
    
    // 비어있는 Array 방출하지만(= SourceObservable가 없기 때문에), 버퍼 사이즈만큼 2개 방출하고 곧 이어 마지막 하나를 방출함
    // 버퍼는 Full Capacity에 다다를 때 Array 요소를 방출하고 명시된 시간만큼 기다리거나 Capacity가 채워지길 기다림
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
      sourceObservable.onNext("🐱")
      sourceObservable.onNext("🐱")
      sourceObservable.onNext("🐱")
    }
  }
}
