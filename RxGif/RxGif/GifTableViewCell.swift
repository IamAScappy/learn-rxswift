//
//  GifTableViewCell.swift
//  RxGif
//
//  Created by yuaming on 09/10/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import Gifu

class GifTableViewCell: UITableViewCell {
  @IBOutlet weak var gifImageView: UIImageView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  // Dispose와 다르게 일회용 리소스. 만약 1회 이상 사용하면 에러 발생함
  var disposable = SingleAssignmentDisposable()
  
  override func prepareForReuse() {
    super.prepareForReuse()
    gifImageView.prepareForReuse()
    gifImageView.image = nil
    disposable.dispose()
    disposable = SingleAssignmentDisposable()
  }
  
  func downloadAndDisplay(gif stringUrl: String) {
    guard let url = URL(string: stringUrl) else { return }
    let request = URLRequest(url: url)
    activityIndicator.startAnimating()
    
    let subscribtion = URLSession.shared.rx
      .data(request: request)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { imageData in
        self.gifImageView.animate(withGIFData: imageData)
        self.activityIndicator.stopAnimating()
      })
    
    disposable.setDisposable(subscribtion)
  }
}

extension UIImageView: GIFAnimatable {
  private struct AssociatedKeys {
    static var animatorKey = "gifu.animator.key"
  }
  
  override open func display(_ layer: CALayer) {
    updateImageIfNeeded()
  }
  
  public var animator: Animator? {
    get {
      guard let animator = objc_getAssociatedObject(self, &AssociatedKeys.animatorKey) as? Animator else {
        let animator = Animator(withDelegate: self)
        self.animator = animator
        return animator
      }
      
      return animator
    }
    
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.animatorKey,
                               newValue as Animator?,
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}
