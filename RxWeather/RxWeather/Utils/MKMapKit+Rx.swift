//
//  MKMapKit+Rx.swift
//  RxWeather
//
//  Created by yuaming on 2018. 9. 12..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import Foundation
import MapKit
import RxSwift
import RxCocoa

// CLLocationManager:에 처럼 RxNKMapViewDelegateProxy, Reactive으로 확장할 수 있음
extension MKMapView: HasDelegate {
  public typealias Delegate = MKMapViewDelegate
}

class RxMKMapViewDelegateProxy: DelegateProxy<MKMapView, MKMapViewDelegate>, DelegateProxyType, MKMapViewDelegate {
  public weak private(set) var mapView: MKMapView?
  
  public init(mapView: ParentObject) {
    self.mapView = mapView
    super.init(parentObject: mapView, delegateProxy: RxMKMapViewDelegateProxy.self)
  }
  
  static func registerKnownImplementations() {
    self.register { RxMKMapViewDelegateProxy(mapView: $0) }
  }
}

extension Reactive where Base: MKMapView {
  public var delegate: DelegateProxy<MKMapView, MKMapViewDelegate> {
    return RxMKMapViewDelegateProxy.proxy(for: base)
  }
  
  // 반환 값이 있는 Delegate를 Rx로 래핑하는 것은 어려움
  // - 반환 값이 있는 Delegate 메서드는 관찰을 위한 것이 아니라 사용자 정의하기 위한 것
  // - 자동적으로 기본 값을 지정하는 것이 중요한 것은 아님
  public func setDelegate(_ delegate: MKMapViewDelegate) -> Disposable {
    // 구현 방법은 Delegate의 기본 구현에 이 호출을 전달하는 방법
    return RxMKMapViewDelegateProxy.installForwardDelegate(
      delegate,
      retainDelegate: false,
      onProxyForObject: self.base)
  }
  
  var overlays: Binder<[MKOverlay]> {
    return Binder(self.base){ mapView, overlays in
      mapView.removeOverlays(mapView.overlays)
      mapView.addOverlays(overlays)
    }
  }
  
  public var regionDidChangeAnimated: ControlEvent<Bool> {
    let source = delegate
      .methodInvoked(#selector(MKMapViewDelegate.mapView(_:regionDidChangeAnimated:)))
      .map { parameters in
        return (parameters[1] as? Bool) ?? false
    }
    
    return ControlEvent(events: source)
  }
}
