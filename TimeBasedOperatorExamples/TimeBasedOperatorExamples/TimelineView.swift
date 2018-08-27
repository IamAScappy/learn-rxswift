//
//  TimelineView.swift
//  TimeBasedOperatorExamples
//
//  Created by yuaming on 2018. 8. 27..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import Foundation
import RxSwift

class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
  static func make() -> TimelineView<E> {
    return TimelineView(width: 400, height: 100)
  }
  
  public func on(_ event: Event<E>) {
    switch event {
    case .next(let value):
      add(.Next(String(describing: value)))
    case .completed:
      add(.Completed())
    case .error(_):
      add(.Error())
    }
  }
}
