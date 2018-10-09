//
//  RxGifTests.swift
//  RxGifTests
//
//  Created by yuaming on 09/10/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import Nimble
import RxNimble
import OHHTTPStubs
import SwiftyJSON

@testable import RxGif

class RxGifTests: XCTestCase {
  let obj = ["array":["foo","bar"], "foo":"bar"] as [String : Any]
  let request = URLRequest(url: URL(string: "http://raywenderlich.com")!)
  let errorRequest = URLRequest(url: URL(string: "http://rw.com")!)
  
  override func setUp() {
    super.setUp()
    stub(condition: isHost("raywenderlich.com")) { _ in
      return OHHTTPStubsResponse(jsonObject: self.obj, statusCode: 200, headers: nil)
    }
    
    stub(condition: isHost("rw.com")) { _ in
      return OHHTTPStubsResponse(error: RxURLSessionError.unknown)
    }
  }
  
  override func tearDown() {
    super.tearDown()
    OHHTTPStubs.removeAllStubs()
  }
  
  func testData() {
    let observable = URLSession.shared.rx.data(request: self.request)
    expect(observable.toBlocking().firstOrNil()).toNot(beNil())
  }
  
  func testString() {
    let observable = URLSession.shared.rx.string(request: self.request)
    let string = "{\"array\":[\"foo\",\"bar\"],\"foo\":\"bar\"}"
    expect(observable.toBlocking().firstOrNil()) == string
  }
  
  func testJSON() {
    let observable = URLSession.shared.rx.json(request: self.request)
    let string = "{\"array\":[\"foo\",\"bar\"],\"foo\":\"bar\"}"
    let json = try? JSON(data: string.data(using: .utf8)!)
    expect(observable.toBlocking().firstOrNil()) == json
  }
  
  func testError() {
    var erroredCorrectly = false
    let observable = URLSession.shared.rx.json(request: self.errorRequest)
    
    do {
      let _ = try observable.toBlocking().first()
      assertionFailure()
    } catch (RxURLSessionError.unknown) {
      erroredCorrectly = true
    } catch {
      assertionFailure()
    }
    
    expect(erroredCorrectly) == true
  }
}

extension BlockingObservable {
  func firstOrNil() -> E? {
    do {
      return try first()
    } catch {
      return nil
    }
  }
}

