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
  }
}

extension UIImageView: GIFAnimatable {
  private struct AssociatedKeys {
    static var AnimatorKey = "gifu.animator.key"
  }
  
  override open func display(_ layer: CALayer) {
    updateImageIfNeeded()
  }
  
  public var animator: Animator? {
    get {
      guard let animator = objc_getAssociatedObject(self, &AssociatedKeys.AnimatorKey) as? Animator else {
        let animator = Animator(withDelegate: self)
        self.animator = animator
        return animator
      }
      
      return animator
    }
    
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.AnimatorKey, newValue as Animator?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}
