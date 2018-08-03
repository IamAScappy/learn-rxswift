//
//  NameModel.swift
//  RxSwiftExamples3
//
//  Created by yuaming on 2018. 8. 4..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import Foundation
import RxDataSources

struct NameModel {
  let name: String
  let number: Int
}

extension NameModel: Equatable, IdentifiableType {
  static func == (lhs: NameModel, rhs: NameModel) -> Bool {
    return lhs.name == rhs.name
  }
  
  var identity: Int {
    return number
  }
}
