//
//  DownloadImageViewController.swift
//  RxSwiftExamples2
//
//  Created by yuaming on 26/07/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Alamofire

class DownloadImageViewController: UIViewController {
  @IBOutlet weak var urlTextField: UITextField!
  @IBOutlet weak var goButton: UIButton!
  @IBOutlet weak var imageView: UIImageView!
  
  fileprivate let disposeBag: DisposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
  }
}

extension DownloadImageViewController {
  fileprivate func bind() {
    goButton.rx.tap.asObservable().flatMap { [weak self] _ -> Observable<Void> in
      return self?.rx.showAlert(title: "다운로드", message: "다운로드 하시겠습니까?") ?? Observable.empty()
    }
    // SerialDispatchQueueScheduler: Main에서 Background로 넘어감
    // .observeOn(SerialDispatchQueueScheduler(qos: .background))
    .withLatestFrom(urlTextField.rx.text.orEmpty)
    // map에서 error 이벤트가 일어나며 안됨. Side Effect가 발생함
    // .map { text -> URL in
    //   return try text.asURL()
    // }
    .flatMap { text -> Observable<URL> in
      guard let url = try? text.asURL() else { return Observable.empty() }
      return Observable.just(url)
    }.filter { url -> Bool in
      let imageExtensions = ["jpg", "png", "gif", "jpeg"]
      return imageExtensions.contains(url.pathExtension.lowercased())
    }.flatMap { (url: URL) -> Observable<String> in
      return Observable.create ({ (observer) -> Disposable in
        let destination = DownloadRequest.suggestedDownloadDestination()
        let download = Alamofire.download(url, to: destination).response(completionHandler: { (response: DefaultDownloadResponse) in
          if let data = response.destinationURL {
            observer.onNext(data.path)
            observer.onCompleted()
          } else {
            observer.onError(RxError.unknown)
          }
        })
        
        return Disposables.create {
          // 다운로드 중에서 뒤로가기 버튼을 누르거나 창을 꺼버리면 다운로드를 취소시킴
          download.cancel()
        }
      })
    }.map { (path: String) -> UIImage in
      guard let image = UIImage(contentsOfFile: path) else {
        throw RxError.noElements
      }
  
      return image
    }
    // ConcurrentMainScheduler
    // ConcurrentDispatchQueueScheduler
    // AtomicIncreasement. Atomic 하지 않음
      
    // SerialDispatchQueueScheduler
    // MainScheduler
    // Atomic 함
      
    // observerOn: 이전 스레드에서 다음 나올 Observer에서 스레드를 지정함
    // subscribeOn: 이전 지정한 쓰레드로 돌아감
      
    // Mainscheduler 로 돌아오지 않으면 정상적인 플로우 아님
    // .observeOn(MainScheduler.instance)
    // subscribeOn: 현재 프로젝트에서 tap에서 이벤트가 발생하기 때문에 사용할 수 없음
    .bind(to: imageView.rx.image)
    .disposed(by: disposeBag)
  }
}

extension Reactive where Base: UIViewController {
  func showAlert(title: String?, message: String?) -> Observable<Void> {
    return Observable.create ({ (observer) -> Disposable in
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      
      alert.addAction(UIAlertAction.init(title: "확인", style: .default, handler: { _ in
        observer.onNext(())
        observer.onCompleted()
      }))
      
      alert.addAction(UIAlertAction.init(title: "취소", style: .cancel, handler: { _ in
        observer.onCompleted()
      }))
      
      self.base.present(alert, animated: true, completion: nil)
      
      return Disposables.create { }
    })
  }
}
