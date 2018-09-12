//
//  ReplayViewController.swift
//  TimeBasedOperatorExamples
//
//  Created by yuaming on 2018. 9. 12..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// Replay, ReplayAll
// - Sequences가 앞으로 이벤트 받을 Subscriber가 지나간 아이템을 받을 수 있는 여부에 대해서 중요함. 이를 제어할 수 있는 연산자가 replay, replayAll
// -
class ReplayViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
  }
  
  private func bind() {
    let elementsPerSecond = 1
    let replayedElements = 5
    let replayDelay: TimeInterval = 5
    
    // Timer 생성
    let sourceObservable = Observable<Int>
      // Interval은 무한한 Observable를 생성함. Counter오 비슷함
      .interval(RxTimeInterval(1.0 / Double(elementsPerSecond)), scheduler: MainScheduler.instance)
      // sourceObservable에서 마지막으로 방출한 replayedElements에 대한 기록으로 새로운 Sequence를 추가함
      // 새로운 Observer가 있을 때마다 Item이 존재한다면 존재하는 요소를 받음. 새로운 요소가 존재한다면 계속 Subscribe 함
      
      // replayedElements, replayDelay 값을 변경해가면서 확인해봐야 함:)
      // 결론적으로 지정한 버퍼 크기만큼 Sequence를 저장하고 Subscribe할 때 공유함
      // 만약 replayedElements 5개, dalay 5라고 설정한 뒤, 구독한다면 5개만큼 이벤트를 저장하고 방출함
      
      
      // replayAll을 확인하기 위해, 예제코드를 .replay(replayedElements)를 replayAll로 교체해봄. 모든 이벤트를 저장하기 때문에 메모리 문제가 발생할 수 있음
      .replay(replayedElements)
      // .replayAll()
    
    // 이벤트 방출의 시각화
    let sourceTimeline = TimelineView<Int>.make()
    let replayedTimeline = TimelineView<Int>.make()
    
    let stack = UIStackView.makeVertical([
      UILabel.makeTitle("replay"),
      UILabel.make("Emit \(elementsPerSecond) per second:"), sourceTimeline,
      UILabel.make("Replay \(replayedElements) after \(replayDelay) sec:"),
      replayedTimeline
    ])
    
    // 방출한 Item 색깔은 초록색, 완료 검은색, 에러 빨간색으로 표시함
    _ = sourceObservable.subscribe(sourceTimeline)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
      _ = sourceObservable.subscribe(replayedTimeline)
    }
    
    // Connectable observable을 생성하기 때문에 Item을 받기 위해서 연결되어 있어야 함
    _ = sourceObservable.connect()
    
    let hostView = setupHostView()
    hostView.addSubview(stack)
    view.addSubview(hostView)
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.topAnchor.constraint(equalTo: hostView.topAnchor, constant: 100).isActive = true
  }
}
