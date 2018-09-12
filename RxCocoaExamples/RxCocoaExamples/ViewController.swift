//
//  ViewController.swift
//  RxCocoaExamples
//
//  Created by yuaming on 2018. 9. 12..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit
import CoreLocation

class ViewController: UIViewController {
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var mapButton: UIButton!
  @IBOutlet weak var geoLocationButton: UIButton!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var searchCityName: UITextField!
  @IBOutlet weak var tempLabel: UILabel!
  @IBOutlet weak var humidityLabel: UILabel!
  @IBOutlet weak var iconLabel: UILabel!
  @IBOutlet weak var cityNameLabel: UILabel!
  
  var disposeBag: DisposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    style()
    
    // MARK: - Part 1
    
    // Subscribe 하는 시점이 늦어지면 이벤트 일부 놓치거나 UI가 바인드 되기 전에 데이터가 보여질 수 있음
    // 그래서, 적절한 시점은 viewDidLoad
    //    ApiController.shared.currentWeather(city: "RxSwift")
    //      .observeOn(MainScheduler.instance)
    //      .subscribe(onNext: { data in
    //        self.tempLabel.text = "\(data.temperature)° C"
    //        self.iconLabel.text = data.icon
    //        self.humidityLabel.text = "\(data.humidity)%"
    //        self.cityNameLabel.text = data.cityName
    //      }).disposed(by: disposeBag)
    
    // ControlPropert<String?>
    // - ObserverType이자 ObservableType. 즉, 새로운 이벤트를 방출 할 수도 있고 Subscribe도 가능함
//    searchCityName.rx.text.asObservable()
//      .filter { ($0 ?? "").count > 0 }
//      .flatMap { text in
//        return ApiController.shared.currentWeather(city: "Error")
//          // 에러를 방출하더라도 흐름이 끊기지 않도록 처리함
//          .catchErrorJustReturn(ApiController.Weather.empty)
//      }.observeOn(MainScheduler.instance)
//      .subscribe(onNext: { data in
//        self.tempLabel.text = "\(data.temperature)° C"
//        self.iconLabel.text = data.icon
//        self.humidityLabel.text = "\(data.humidity)%"
//        self.cityNameLabel.text = data.cityName
//      }).disposed(by: disposeBag)
    
//    let search = searchCityName.rx.text.asObservable()
//      .filter { ($0 ?? "").count > 0 }
//      .flatMap { text in
      // flatMap에서 flatMapLatest를 교체하면서 Observable Rx의 재사용 가능해짐
      // 바른 코드 설계는 가독성이 낮은 일회성 코드를 가독성이 높은 재사용 가능한 코드로 바꾸는 것
      
      // RxCocoa의 Trait
      // - Observable Sequence 객체가 UI(User Interface) 영역과 연결될 수 있도록 도와줌
      // - 에러를 방출할 수 없고, 메인 스케줄러를 Observe, Subscribe함
      
      // RxCocoa의 Trait 요소
      // - ControlProperty: Rx Extension을 통해 사용할 수 있음. 데이터와 UI 영역을 연결
      // - ControlEvent: UIControlEvents를 현재 상태를 계속 두고 사용할 수 있음
      // - Driver: UI 변경이 Background Thread에서 일어나는 것을 방지함. 모든 작업이 Main Thread에서 일어남
      // - RxCocoa Trait를 억지로 사용할 필요 없지만, 처음에서 Subject나 Observable만 쓰는 것도 나쁘지 않음
      // - 그러나, 만약 컴파일 과정이나 UI와 관련된 어떤 작업을 확인하고 싶을 때, Trait은 시간 절약하는데 도움을 줌
//      .flatMapLatest { text in
//        return ApiController.shared.currentWeather(city: text ?? "Error")
//          .catchErrorJustReturn(ApiController.Weather.empty)
//      }.share(replay: 1).observeOn(MainScheduler.instance)
      // Observable가 Driver로 전환됨
      // asDriver(onErrorDriveWith:): 수동적으로 에러를 관리할 수 있음. 새로운 Sequence를 반환함
      // asDriver(onErrorRecover:): 새로운 Driver와 사용할 수 있음. Driver가 에러받았을 때 복구용도로 사용할 수 있음
//      }.asDriver(onErrorJustReturn: ApiController.Weather.empty)
    
    // MARK: - Part 2
    // RxCocoa unowned vs weak
    // - 순환참조 되는 것을 막기 위해 weak 사용함. 그러나 옵셔널 타입이 됨
    // - unowned는 이런 옵셔널 타입이 되는 것을 회피하고 싶을 때 사용함
    
    // - RxSwift, RxCocoa에서는 이 부분에 대한 좋은 가이드라인이 있음
    // - Nothing: 절대 Release 되지 않는 싱글톤 내부 또는 Root View Controller
    // - Unowned: 클로저 작업이 완료한 후, Release된 모든 View Controller 내부
    // - Weak: Nothing, Unowned 제외한 모든 상황. 그러나 Raywenderlich 가이드에서 Unowned 사용을 권하지 않음
    let searchInput = searchCityName.rx.controlEvent(.editingDidEndOnExit).asObservable()
      .map { self.searchCityName.text }
      .filter { ($0 ?? "").count > 0 }
    
    let textSearch = searchInput.flatMap { text in
        return ApiController.shared.currentWeather(city: text ?? "Error")
          .catchErrorJustReturn(ApiController.Weather.dummy)
      }
    
    let mapInput = mapView.rx.regionDidChangeAnimated
      .skip(1)
      .map { _ in self.mapView.centerCoordinate }
    
    let mapSearch = mapInput.flatMap { coordinate in
      return ApiController.shared.currentWeather(lat: coordinate.latitude, lon: coordinate.longitude)
        .catchErrorJustReturn(ApiController.Weather.dummy)
    }

    let locationManager = CLLocationManager()
    
//    geoLocationButton.rx.tap.asObservable()
//      .subscribe(onNext: { _ in
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//      }).disposed(by: disposeBag)
    
    let geoInput = geoLocationButton.rx.tap.asObservable()
      .do(onNext: { _ in
        // http://seorenn.blogspot.com/2014/11/ios-8-locationmanager.html
        // 가짜 위치를 시뮬레이터에서 셋팅 가능함
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
      })
    
//    locationManager.rx.didUpdateLocations.asObservable()
//      .subscribe(onNext: { (location) in
//        print(location)
//      }).disposed(by: disposeBag)
    
    let currentLocation = locationManager.rx.didUpdateLocations.asObservable()
      .map { location in
        return location[0]
      }.filter { location in
        // 받아온 데이터가 100 미터 이내로 정확한 값인지 확인함
        return location.horizontalAccuracy < kCLLocationAccuracyHundredMeters
      }
    
    let geoLocation = geoInput.flatMap { currentLocation.take(1) }
    
    let geoSearch = geoLocation.flatMap { location in
      return ApiController.shared.currentWeather(lat: location.coordinate.latitude,
                                                 lon: location.coordinate.longitude)
        .catchErrorJustReturn(ApiController.Weather.dummy)
    }
    
    let search = Observable.from([geoSearch, textSearch, mapSearch])
      .merge()
      .asDriver(onErrorJustReturn: ApiController.Weather.dummy)

    // searchInput과 search를 통해 이벤트 수신 여부에 따라 true 또는 false로 구분될 수 있음
    // 만약 데이터를 수신하였다면 Observable 합쳐질 수 있음
    // 앱이 서버로부터 데이터를 수신했는지 여부에 따라서 구분여부에 따라 isAnimating을 추가할 수 있음
    let running = Observable.from([searchInput.map { _ in true },
                                   search.map { _ in false }.asObservable(),
                                   geoInput.map { _ in true },
                                   mapInput.map { _ in true }])
      .merge()
      // 앱이 시작할 때 모든 Label를 수동적으로 숨기게 할 필요없이 편리하게 해줌
      .startWith(true)
      .asDriver(onErrorJustReturn: false)
    
    running.skip(1)
      .drive(activityIndicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    running
      .drive(tempLabel.rx.isHidden)
      .disposed(by: disposeBag)
    
    running
      .drive(humidityLabel.rx.isHidden)
      .disposed(by: disposeBag)
    
    running
      .drive(iconLabel.rx.isHidden)
      .disposed(by: disposeBag)
    
    running
      .drive(cityNameLabel.rx.isHidden)
      .disposed(by: disposeBag)
    
    // RxCocoa Binding
    // - 단방향 데이터 스트림. 앱에서 데이터 흐름을 단순화 하는 방법
    // - 양방향은 어떻게 구현해야 하나 ?
    
    // - Producer: 값을 만듦
    search.map { $0.cityName }
      // - Receiver: 값을 수신하고 처리함. 하지만 반환하지 못함
//      .bind(to: cityNameLabel.rx.text)
      .drive(cityNameLabel.rx.text)
      .disposed(by: disposeBag)

    search.map { "\($0.humidity)%" }
//      .bind(to: humidityLabel.rx.text)
      .drive(humidityLabel.rx.text)
      .disposed(by: disposeBag)

    search.map { $0.icon }
//      .bind(to: iconLabel.rx.text)
      .drive(iconLabel.rx.text)
      .disposed(by: disposeBag)

    search.map { "\($0.temperature)℃" }
//      .bind(to: tempLabel.rx.text)
      .drive(tempLabel.rx.text)
      .disposed(by: disposeBag)
    
    mapButton.rx.tap
      .subscribe(onNext: {
        self.mapView.isHidden = !self.mapView.isHidden
      })
      .disposed(by: disposeBag)
    
    mapView.rx.setDelegate(self).disposed(by: disposeBag)
    
    search.map { [$0.overlay()] }
      .drive(mapView.rx.overlays)
      .disposed(by: disposeBag)
    
    // Signal
    // - 이벤트가 연결되었을 때만 공유함
    // - 모든 이벤트가 Main Thread에서 처리됨
    // - Subscribe 한 후, 마지막 이벤트에 대해서는 replay하지 않음
    // - 상황에 따라 어떤 것을 사용해야 할 지 판단할 때, 마지막 이벤트에 대한 Replay가 필요한가? 생각해보는 것이 좋음. 만약 Replay가 필요하지 않으면 Signal을 사용하고, 필요하다면 Driver를 사용하면 됨
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    Appearance.applyBottomLine(to: searchCityName)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - Style
  private func style() {
    view.backgroundColor = UIColor.aztec
    searchCityName.textColor = UIColor.ufoGreen
    tempLabel.textColor = UIColor.cream
    humidityLabel.textColor = UIColor.cream
    iconLabel.textColor = UIColor.cream
    cityNameLabel.textColor = UIColor.cream
  }
}

extension ViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let overlay = overlay as? ApiController.Weather.Overlay {
      let overlayView = ApiController.Weather.OverlayView(overlay: overlay, overlayIcon: overlay.icon)
      return overlayView
    }
    return MKOverlayRenderer()
  }
}
