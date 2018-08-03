//
//  BlackJack.swift
//  RxSwiftExmaples1
//
//  Created by yuaming on 2018. 8. 3..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class BlackJack {
  fileprivate let cards = [
    ("🂡", 11), ("🂢", 2), ("🂣", 3), ("🂤", 4), ("🂥", 5), ("🂦", 6), ("🂧", 7), ("🂨", 8), ("🂩", 9), ("🂪", 10), ("🂫", 10), ("🂭", 10), ("🂮", 10),
    ("🂱", 11), ("🂲", 2), ("🂳", 3), ("🂴", 4), ("🂵", 5), ("🂶", 6), ("🂷", 7), ("🂸", 8), ("🂹", 9), ("🂺", 10), ("🂻", 10), ("🂽", 10), ("🂾", 10),
    ("🃁", 11), ("🃂", 2), ("🃃", 3), ("🃄", 4), ("🃅", 5), ("🃆", 6), ("🃇", 7), ("🃈", 8), ("🃉", 9), ("🃊", 10), ("🃋", 10), ("🃍", 10), ("🃎", 10),
    ("🃑", 11), ("🃒", 2), ("🃓", 3), ("🃔", 4), ("🃕", 5), ("🃖", 6), ("🃗", 7), ("🃘", 8), ("🃙", 9), ("🃚", 10), ("🃛", 10), ("🃝", 10), ("🃞", 10)
  ]
  
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
        
        if points(for: hand) > 21 {
          dealtHand.onError(HandError.busted)
        } else {
          dealtHand.onNext(hand)
        }
      }
      
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

private extension BlackJack {
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
