//
//  ImagePickerController+Rx.swift
//  RxSwiftExamples2
//
//  Created by yuaming on 27/07/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

class RxImagePickerDelegateProxy: RxNavigationControllerDelegateProxy, UIImagePickerControllerDelegate {
  init(imagePicker: UIImagePickerController) {
    super.init(navigationController: imagePicker)
  }
  
  static func registerImagePickerDelegateProxy(){
    RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }
  }
}


extension Reactive where Base: UIImagePickerController {
  static func create(parent: UIViewController?,
                     animated: Bool = true,
                     configureImagePicker: @escaping (UIImagePickerController) throws -> () = { x in })
    -> Observable<[String: Any]> {
      return Observable<UIImagePickerController>.create { [weak parent] observer in
        let imagePicker = UIImagePickerController()
        let dismissDisposable = imagePicker.rx.didCancel.subscribe(onNext: { [weak imagePicker] _ in
          guard let imagePicker = imagePicker else { return }
          imagePicker.dismissViewController(animated: animated)
        })
        
        do {
          try configureImagePicker(imagePicker)
        } catch let error {
          observer.onError(error)
          return Disposables.create()
        }
        
        guard let parent = parent else {
          observer.onCompleted()
          return Disposables.create()
        }
        
        parent.present(imagePicker, animated: animated, completion: nil)
        observer.onNext(imagePicker)
        
        return Disposables.create(dismissDisposable, Disposables.create {
          imagePicker.dismissViewController(animated: animated)
        })
      }.flatMap {
        $0.rx.didFinishPickingMediaWithInfo
      }.take(1)
  }
}

extension Reactive where Base: UIImagePickerController {
  var didFinishPickingMediaWithInfo: Observable<[String : Any]> {
    return delegate.methodInvoked(
        #selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
      .map{ result -> [String: Any] in
        guard let info = result[1] as? [String: Any] else {
          throw RxCocoaError.castingError(object: result[1], targetType: [String: Any].self)
        }
        
        return info
      }
  }
  
  var didCancel: Observable<()> {
    return delegate.methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:))).map {_ in () }
  }
}

extension UIViewController {
  func dismissViewController(animated: Bool = true) {
    guard !(self.isBeingDismissed || self.isBeingPresented) else {
      DispatchQueue.main.async {
        self.dismissViewController(animated: animated)
      }
      
      return
    }
    
    if let _ = self.presentingViewController {
      self.dismiss(animated: animated, completion: nil)
    }
  }
}
