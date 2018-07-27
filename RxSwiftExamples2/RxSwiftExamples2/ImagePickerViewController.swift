//
//  ImagePickerTestViewController.swift
//  RxSwiftExamples2
//
//  Created by yuaming on 27/07/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class ImagePickerViewController: UIViewController {
  @IBOutlet weak var showButton: UIButton!
  @IBOutlet var imageView: UIImageView!
  @IBOutlet weak var uploadButton: UIButton!
  @IBOutlet weak var progressbar: UIProgressView!
  
  fileprivate var disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
  }
}

extension ImagePickerViewController {
  func bind() {
    showButton.rx.tap.asObservable().flatMapLatest { [weak self] _ -> Observable<[String: Any]> in
      return UIImagePickerController.rx.create(parent: self, animated: true, configureImagePicker: { (picker) in
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
      })
    }.map { info -> UIImage? in
      return info[UIImagePickerControllerOriginalImage] as? UIImage
    }.subscribe( onNext: { [weak self] (image: UIImage?) in
      guard let `self` = self else { return }
      self.imageView.image = image
      self.uploadButton.isHidden = false
      self.progressbar.isHidden = false
      self.uploadButton.isEnabled = true
    }).disposed(by: disposeBag)
    
    uploadButton.rx.tap.flatMap { [weak self] _ -> Observable<Void> in
      guard let `self` = self else { return Observable.empty() }
      return self.rx.showOKCancelAlert(title: "업로드", message: "업로드를 하시겠습니까?")
    }.map { [weak self] () -> UIImage? in
      return self?.imageView.image
    }.flatMap { (image) -> Observable<Float> in
      guard let image = image else { return Observable.empty() }
      
      return API.upload(image: image).do(onCompleted: { [weak self] in
          self?.uploadButton.isEnabled = false
        })
    }.subscribe(onNext: { [weak self] (progress) in
        self?.progressbar.progress = progress
    }).disposed(by: disposeBag)
    
  }
}

extension Reactive where Base: UIViewController {
  func showOKCancelAlert(title: String?, message: String?) -> Observable<Void> {
    return Observable.create({ (observer) -> Disposable in
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: { _ in
        observer.onNext(())
        observer.onCompleted()
      }))
      
      alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { _ in
        observer.onCompleted()
      }))
      
      self.base.present(alert, animated: true, completion: nil)
      return Disposables.create { }
    })
  }
}

struct API {
  static func upload(image: UIImage) -> Observable<Float> {
    guard let data = UIImagePNGRepresentation(image) else { return Observable.empty() }
    let imageSize: Float = Float(data.count)
    return Observable<Float>.create({ (observer) -> Disposable in
      for i in stride(from: 0, to: imageSize, by: 40) {
        observer.onNext( Float(i / imageSize) )
      }
      
      observer.onNext( Float(1) )
      observer.onCompleted()
      
      return Disposables.create { }
    }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background)).observeOn(MainScheduler.instance)
  }
}
