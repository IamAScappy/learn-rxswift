//
//  ViewController.swift
//  RxWeather
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
  fileprivate var cache = [String: Weather]()
  fileprivate let maxAttempts = 4
  
  typealias Weather = ApiController.Weather
  
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
    
    
    // MARK: - PART 3
    // 에러가 주로 발생하는 경우: 인터넷 접속 불가능, 잘못된 입력, API 혹은 HTTP 에러
    
    // RxSwift 에러 관리 방법
    // - Catch: defaultValue로 Error 복구함
    // - Retry: 제한적 또는 무제한으로 재시도
    
    // Pods/RxCocoa/URLSession+Rx.swift: RxSwift를 사용하여 필요에 따라 Swift 코드를 작성하는 방법, 그리고 필요에 따라 RxSwift 스타일의 오류 처리 방법을 보여줌
    /*
     public func data(request: URLRequest) -> Observable<Data> {
      return response(request: request).map { pair -> Data in
        if 200 ..< 300 ~= pair.0.statusCode {
          return pair.1
        } else {
          throw RxCocoaURLError.httpRequestFailed(response: pair.0, data: pair.1)
        }
      }
     }
     */
    
    // Catch 관련 메서드
    // - func catchError(_ handler:) -> RxSwift.Observable<Self.E>
    // - func catchErrorJustReturn(_ element:) -> RxSwift.Observable<Self.E> => 에러가 무엇이든 상관없이 같은 값을 반환함
    
    // Retry 관련 메서드
    // - func retry(_ maxAttemptCount:) -> Observable<E>
    // - func retryWhen(_ notificationHandler:) -> Observable<E>
    
    // 그러나, 에러는 Observable 체이닝 과정에서 발생함. 에러를 따로 관리하지 않는다면 에러 결과 값이 그대로 넘어가 Subcribe 하는 과정에서 Dispose 시킴. 즉, Observable는 완전히 종료하고 에러가 구독한 이후 과정을 진행하지 않음. 이 앱 기준으로 검색 과정 중 404 에러가 발생하여 처리하지 않는다면 UI 업데이트가 중단되버리는 것은 사용자에게 좋은 경험은 아님
    
    // Materialize / dematerialize
    /*
     * 이벤트 History를 남길 수 있음
     * materialize / dematerialize는 함께 사용함. 이 둘을 함께 쓰면 원본 observable을 완전히 분해할 수 있음. 다만, 특정상황을 처리할 수 있는 다른 옵션이 없을 때만 사용해야 함. 자주 사용하지 않음
     observableToLog.materialize()
      .do(onNext: { (event) in
        myAdvancedLogEvent(event)
      })
    */
    let retryHandler: (Observable<Error>) -> Observable<Int> = { error in
      return error.enumerated().flatMap { (attempt, error) -> Observable<Int> in
        // 원래 에러 Observable과 재시도 이전에 얼마나 지연되야 하는지 정의한 Observable와 결합함
        if attempt >= self.maxAttempts - 1 {
          return Observable.error(error)
          // API Key 관련 에러
        } else if let casted = error as? ApiController.ApiError, casted == .invalidKey {
          return ApiController.shared.apiKey
            .filter { $0 != "" }
            .map { _ in return 1 }
        }
        
        print("== Retrying after \(attempt + 1) seconds ==")
        
        return Observable<Int>.timer(Double(attempt + 1),
                                     scheduler: MainScheduler.instance).take(1)
      }
    }
    
    let textSearch = searchInput.flatMap { text in
        return ApiController.shared.currentWeather(city: text ?? "Error")
          // 에러는 보통 retry, catch 연산자로 관리되지만,
          // Side Effect를 발생시키고 싶거나 사용자 인터페이스에서 메시지를 띄우고 싶다면 do 연산자를 사용할 수 있음
          .do(onNext: { (data) in
            if let text = text {
              self.cache[text] = data
            }
          }, onError: { [weak self] e in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
              InfoView.showIn(viewController: strongSelf, message: "An error occurred")
            }
          })
          .catchErrorJustReturn(ApiController.Weather.empty)
          // 2. retry: 성공할 때까지 3번 반복하고 4번째 에러가 발생하는 순간 catchError로 이동함
//          .retry(3)
          /*
           subscription -> error
           delay and retry after 1 second
           
           subscription -> error
           delay and retry after 3 seconds
           
           subscription -> error
           delay and retry after 5 seconds
           
           subscription -> error
           delay and retry after 10 seconds
           
           * Swift에 이러한 결과를 만들기 위해서 코드가 복잡해짐. RxSwift는 간결해짐
           * 내부 Observable 항목이 어떤 값을 반환해야 하는지 확인해야 하며, Trigger가 어떤 유형이 될 수 있는지 고려해야 함
           * 즉, Delay Sequence와 함께 4번 재시도 하는 것임
          */
          .retryWhen(retryHandler)
          // 1. Catch
          .catchError({ (error) -> Observable<ApiController.Weather> in
            if let text = text, let cachedData = self.cache[text] {
              return Observable.just(cachedData)
            } else {
              return Observable.just(ApiController.Weather.empty)
            }
          })
      
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
  
  private func showError(error e: Error) {
    if let e = e as? ApiController.ApiError {
      switch (e) {
      case .cityNotFound:
        InfoView.showIn(viewController: self, message: "City Name is invalid")
      case .serverFailure:
        InfoView.showIn(viewController: self, message: "Server error")
      case .invalidKey:
        InfoView.showIn(viewController: self, message: "Key is invalid")
      }
    } else {
      InfoView.showIn(viewController: self, message: "An error occurred")
    }
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
