//
//  CLLocationManager+Rx.swift
//  RxCocoaExamples
//
//  Created by yuaming on 2018. 9. 12..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

// MARK:
// - 일단 따라치기 했으나 헷갈림
// - Proxy 패턴이 헷갈림. 찾아보기
// - DelegateProxy.swift, DelegateProxyType.swift가 무엇인가?
// - CoreLocation에서 CLLocationManager, CLLocationManagerDelegate가 무슨 역할을 하는지 알아봐야 할듯
// - RxCLLocationManagerDelegateProxy 무엇인가?
// - methodInvoked ?

// CLLocationManager 확장을 통해 현재 위치 확인하기
// - RxCocoa는 UI뿐만 아니라, Apple의 공식 프레임워크들을 래핑하여 간단하고 강력한 방법으로 사용자화함

// NSObject를 상속한 모든 클래스가 Rx- 사용하는 방법
// - RxCocoa 폴더 내에 _RxDelegateProxy.h, _RxDelegateProxy.m라 명명된 Objective-C 파일이 존재함
// - Swift의 DelegateProxy.swift, DelegateProxyType.swift와 같은 역할을 함
// - Delegate, DataSource를 사용하는 모든 프레임워크들과 RxSwift를 연결을 구현함
extension CLLocationManager: HasDelegate {
  public typealias Delegate = CLLocationManagerDelegate
}

// 1. RxCLLocationManagerDelegateProxy는 Observable 생성하고 Subscribe 한 후, CLLocationManager 객체에 연결하는 Proxy가 됨. HasDelegate에 의해 단순화 됨. Proxy Delegate의 초기화를 추가하고 참조해야 함
class RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {

  // 2. 두 가지 함수를 이용해서, Delegate를 초기화하고, 모든 구현을 등록할 수 있으며 CLLocationManager 객체에서 연결된 Observable로 데이터를 옮길 때 사용하는 Proxy
  // 3. RxCocoa에서 Delegate Proxy 패턴을 쓰기 위하여 클래스를 확장하는 방법
  public weak private(set) var locationManager: CLLocationManager?
  
  public init(locationManager: ParentObject) {
    self.locationManager = locationManager
    super.init(parentObject: locationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
  }
  
  static func registerKnownImplementations() {
    self.register { RxCLLocationManagerDelegateProxy(locationManager: $0) }
  }
}

// 4. Reactive Extension은 .rx 키워드를 통해 CLLocationManager 객체의 메서드를 구현한 것이며 이제부터 CLLocationManager 객체에서 .rx 키워드를 사용할 수 있음
// 5. 아직 Observable의 데이터를 주고 받지 않음
extension Reactive where Base: CLLocationManager {
  public var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
    return RxCLLocationManagerDelegateProxy.proxy(for: base)
  }
  
  // 6. didUpdateLocations는 모든 호출을 수신하고 데이터를 가져와서 CLLocation.methodInvoked(_:)의 Array로 타입 캐스팅됨
  // 7. methodInvoked(_:)가 지정한 메서드가 호출될 때마다 Observable을 반환
  // 8. 이벤트에 포함한 요소는 메서드가 호출한 Parameter의 Array
  // 9. Array의 parameters[1]로 접근하고 CLLocation의 Array로 타입 캐스팅됨
  var didUpdateLocations: Observable<[CLLocation]> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:))).map { parameters in
      return parameters[1] as! [CLLocation]
    }
  }
}
