//
//  Utils.swift
//  RxSwiftExample
//
//  Created by yuaming on 28/06/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

// MARK: - Examples Supported Code

// Functions
func example(of description: String, action: () -> Void) {
  print("\n--- Example of:", description, "---")
  action()
}

func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
  print(label, event.element ?? event.error ?? event)
}

// Constants
let woong = "Woong"
let gamja = "Gamja"
let sj = "SJ"
let hj = "HJ"

let itsNotMyFault = "It’s not my fault."
let doOrDoNot = "Do. Or do not. There is no try."
let lackOfFaith = "I find your lack of faith disturbing."
let eyesCanDeceive = "Your eyes can deceive you. Don’t trust them."
let stayOnTarget = "Stay on target."
let iAmYourFather = "Luke, I am your father"
let useTheForce = "Use the Force, Luke."
let theForceIsStrong = "The Force is strong with this one."
let mayTheForceBeWithYou = "May the Force be with you."
let mayThe4thBeWithYou = "May the 4th be with you."

// Enums
enum FileReadError: Error {
  case fileNotFound, unreadable, encodingFailed
}

enum Quote: Error {
  case neverSaidThat
}

enum MyError: Error {
  case anError
}

enum Droid: Error {
  case OU812
}
