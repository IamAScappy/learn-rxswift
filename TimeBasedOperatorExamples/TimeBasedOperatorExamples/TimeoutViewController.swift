//
//  TimeoutViewController.swift
//  TimeBasedOperatorExamples
//
//  Created by yuaming on 2018. 9. 12..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimeoutViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
  }

  private func bind() {
    let button = UIButton(type: .system)
    button.setTitle("Press me now!", for: .normal)
    button.sizeToFit()
    
    let tapsTimeline = TimelineView<String>.make()
    
    let stack = UIStackView.makeVertical([
      button,
      UILabel.make("Taps on button above"),
      tapsTimeline])
    
    // Timeout
    // - RxError.TimeoutError 에러 이벤트 방출하기 때문에 Sequence가 완전 종료됨
    let _ = button
      .rx.tap
      .map { _ in "•" }
      .timeout(5, other: Observable.just("X"), scheduler: MainScheduler.instance)
      .subscribe(tapsTimeline)
    
    let hostView = setupHostView()
    hostView.addSubview(stack)
    view.addSubview(hostView)
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.topAnchor.constraint(equalTo: hostView.topAnchor, constant: 100).isActive = true
  }
}
