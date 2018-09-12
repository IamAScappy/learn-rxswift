//
//  UIViewController+.swift
//  TimeBasedOperatorExamples
//
//  Created by yuaming on 2018. 9. 12..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import UIKit

extension UIViewController {
  func setupHostView() -> UIView {
    let hostView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 640))
    hostView.backgroundColor = .white
    return hostView
  }
}
