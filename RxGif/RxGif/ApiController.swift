//
//  ApiController.swift
//  RxGif
//
//  Created by yuaming on 09/10/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

class ApiController {
  
  static let shared = ApiController()
  
  private let apiKey = "CWEu9CfACLBxvUnymhuIapfk7mSfFvVO"
  
  func search(text: String) -> Observable<[JSON]> {
    let url = URL(string: "http://api.giphy.com/v1/gifs/search")!
    var request = URLRequest(url: url)
    let keyQueryItem = URLQueryItem(name: "api_key", value: apiKey)
    let searchQueryItem = URLQueryItem(name: "q", value: text)
    let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
    
    urlComponents.queryItems = [searchQueryItem, keyQueryItem]
    
    request.url = urlComponents.url!
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    return Observable.just([])
  }
}
