//
//  BlackJack.swift
//  RxSwiftExample
//
//  Created by yuaming on 28/06/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BlackJack: UIViewController {
  fileprivate let cards = [
    ("🂡", 11), ("🂢", 2), ("🂣", 3), ("🂤", 4), ("🂥", 5), ("🂦", 6), ("🂧", 7), ("🂨", 8), ("🂩", 9), ("🂪", 10), ("🂫", 10), ("🂭", 10), ("🂮", 10),
    ("🂱", 11), ("🂲", 2), ("🂳", 3), ("🂴", 4), ("🂵", 5), ("🂶", 6), ("🂷", 7), ("🂸", 8), ("🂹", 9), ("🂺", 10), ("🂻", 10), ("🂽", 10), ("🂾", 10),
    ("🃁", 11), ("🃂", 2), ("🃃", 3), ("🃄", 4), ("🃅", 5), ("🃆", 6), ("🃇", 7), ("🃈", 8), ("🃉", 9), ("🃊", 10), ("🃋", 10), ("🃍", 10), ("🃎", 10),
    ("🃑", 11), ("🃒", 2), ("🃓", 3), ("🃔", 4), ("🃕", 5), ("🃖", 6), ("🃗", 7), ("🃘", 8), ("🃙", 9), ("🃚", 10), ("🃛", 10), ("🃝", 10), ("🃞", 10)
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    play()
  }
  
  func play() {
    example(of: "BlackJack") {
      let disposeBag = DisposeBag()
      
      let dealtHand = PublishSubject<[(String, Int)]>()
      
      func deal(_ cardCount: UInt) {
        var deck = cards
        var cardsRemaining: UInt32 = 52
        var hand = [(String, Int)]()
        
        for _ in 0..<cardCount {
          let randomIndex = Int(arc4random_uniform(cardsRemaining))
          hand.append(deck[randomIndex])
          deck.remove(at: randomIndex)
          cardsRemaining -= 1
        }
        
        // Add code to update dealtHand
        if points(for: hand) > 21 {
          dealtHand.onError(HandError.busted)
        } else {
          dealtHand.onNext(hand)
        }
      }
      
      // Add subscription to dealtHand
      dealtHand.subscribe(
        onNext: { hand in
          print(self.cardString(for: hand), "for", self.points(for: hand), "points")
        }, onError: { error in
          print(String(describing: error))
        }
      ).disposed(by: disposeBag)
      
      deal(3)
    }
  }
}

fileprivate extension BlackJack {
  func cardString(for hand: [(String, Int)]) -> String {
    return hand.map { $0.0 }.joined(separator: "")
  }
  
  func points(for hand: [(String, Int)]) -> Int {
    return hand.map { $0.1 }.reduce(0, +)
  }
  
  enum HandError: Error {
    case busted
  }
}
