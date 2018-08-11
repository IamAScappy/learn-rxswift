//
//  Utils.swift
//  RxSwiftExamples1
//
//  Created by yuaming on 2018. 8. 11..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import RxSwift
import RxCocoa
import Foundation

class Utils: NSObject {
  // MARK: - Examples Supported Code
  // Functions
  static func example(of description: String, action: () -> Void) {
    Swift.print("\n--- Example of:", description, "---")
    action()
  }
  
  static func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    Swift.print(label, event.element ?? event.error ?? event)
  }
}
