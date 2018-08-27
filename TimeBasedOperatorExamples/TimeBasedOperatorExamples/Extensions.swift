//
//  Extensions.swift
//  TimeBasedOperatorExamples
//
//  Created by yuaming on 2018. 8. 27..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import UIKit

// MARK: - UILabel
extension UILabel {
  class func make(_ title: String) -> UILabel {
    let label = UILabel()
    label.text = title
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    return label
  }
  
  class func makeTitle(_ title: String) -> UILabel {
    let label = make(title)
    label.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize * 2.0)
    label.textAlignment = .center
    return label
  }
}

// MARK: - UIStackView
extension UIStackView {
  class func makeVertical(_ views: [UIView]) -> UIStackView {
    let stack = UIStackView(arrangedSubviews: views)
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.distribution = .fill
    stack.axis = .vertical
    stack.spacing = 15
    return stack
  }
  
  func insert(_ view: UIView, at index: Int) {
    insertArrangedSubview(view, at: index)
  }
  
  func keep(atMost: Int) {
    while arrangedSubviews.count > atMost {
      let view = arrangedSubviews.last!
      removeArrangedSubview(view)
      view.removeFromSuperview()
    }
  }
}

// MARK: - DispatchSource
extension DispatchSource {
  class func timer(interval: Double, queue: DispatchQueue, handler: @escaping () -> Void) -> DispatchSourceTimer {
    let source = DispatchSource.makeTimerSource(queue: queue)
    source.setEventHandler(handler: handler)
    source.scheduleRepeating(deadline: .now(), interval: interval, leeway: .nanoseconds(0))
    source.resume()
    return source
  }
}
