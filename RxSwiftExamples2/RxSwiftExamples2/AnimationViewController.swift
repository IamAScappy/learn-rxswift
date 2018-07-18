//
//  AnimationViewController.swift
//  RxSwiftExamples2
//
//  Created by yuaming on 18/07/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AnimationViewController: UIViewController {
  @IBOutlet weak var upButton: UIButton!
  @IBOutlet weak var downButton: UIButton!
  @IBOutlet weak var leftButton: UIButton!
  @IBOutlet weak var rightButton: UIButton!
  @IBOutlet weak var box: UIView!
  
  fileprivate var disposeBag: DisposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
  }
}

extension AnimationViewController {
  fileprivate func bind() {
    upButton.rx.tap
      .map { Animation.up }
      .bind(to: box.rx.animation)
      .disposed(by: disposeBag)
    
    downButton.rx.tap
      .map { Animation.down }
      .bind(to: box.rx.animation)
      .disposed(by: disposeBag)
    
    leftButton.rx.tap
      .map { Animation.left }
      .bind(to: box.rx.animation)
      .disposed(by: disposeBag)
    
    rightButton.rx.tap
      .map { Animation.right }
      .bind(to: box.rx.animation)
      .disposed(by: disposeBag)
    
//    upButton.rx.tap
//      .map { Animation.up }
//      .subscribe(onNext: { [weak self] animation in
//        guard let `self` = self else { return }
//
//        UIView.animate(withDuration: 0.5) {
//          self.box.transform = animation.transform(self.box.transform)
//        }
//      }).disposed(by: disposeBag)
//
//    downButton.rx.tap
//      .map { Animation.down }
//      .subscribe(onNext: { [weak self] animation in
//        guard let `self` = self else { return }
//
//        UIView.animate(withDuration: 0.5) {
//          self.box.transform = animation.transform(self.box.transform)
//        }
//      }).disposed(by: disposeBag)
//
//    leftButton.rx.tap
//      .map { Animation.left }
//      .subscribe(onNext: { [weak self] animation in
//        guard let `self` = self else { return }
//
//        UIView.animate(withDuration: 0.5) {
//          self.box.transform = animation.transform(self.box.transform)
//        }
//      }).disposed(by: disposeBag)
//
//    rightButton.rx.tap
//      .map { Animation.right }
//      .subscribe(onNext: { [weak self] animation in
//        guard let `self` = self else { return }
//
//        UIView.animate(withDuration: 0.5) {
//          self.box.transform = animation.transform(self.box.transform)
//        }
//      }).disposed(by: disposeBag)
  }
}

// Binder
// - Boxing: view.rx.animation
// - Binder 안에서 코드가 길어지는 것을 경계해야 함
extension Reactive where Base: UIView {
  var animation: Binder<Animation> {
    return Binder(self.base, binding: { (view, animation) in
      UIView.animate(withDuration: 0.5) {
        view.transform = animation.transform(view.transform)
      }
    })
  }
}

enum Animation {
  case left, right, up, down
}

extension Animation {
  func transform(_ transform: CGAffineTransform) -> CGAffineTransform {
    switch self {
    case .left: return transform.translatedBy(x: -50, y: 0)
    case .right: return transform.translatedBy(x: 50, y: 0)
    case .up: return transform.translatedBy(x: 0, y: -50)
    case .down: return transform.translatedBy(x: 0, y: 50)
    }
  }
}
