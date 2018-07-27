//
//  ColorViewController.swift
//  RxSwiftExamples2
//
//  Created by yuaming on 27/07/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ColorViewController: UIViewController {
  @IBOutlet weak var hexColorTextField: UITextField!
  @IBOutlet weak var rSlider: UISlider!
  @IBOutlet weak var gSlider: UISlider!
  @IBOutlet weak var bSlider: UISlider!
  @IBOutlet weak var applyButton: UIButton!
  @IBOutlet weak var rLabel: UILabel!
  @IBOutlet weak var gLabel: UILabel!
  @IBOutlet weak var bLabel: UILabel!
  @IBOutlet weak var colorView: UIView!
  @IBOutlet weak var doneButton: UIBarButtonItem!
  @IBOutlet weak var cancelButton: UIBarButtonItem!
  
  fileprivate var disposeBag: DisposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
  }
}

extension ColorViewController {
  fileprivate func bind() {
    let rObservable = rSlider.rx.value.map { CGFloat($0) }
    let gObservable = gSlider.rx.value.map { CGFloat($0) }
    let bObservable = bSlider.rx.value.map { CGFloat($0) }
    
    // .map { UIColor(red: $0, green: $0, blue: $0, alpha: 1) }
    // .bind(to: colorView.rx.backgroundColor)
    // .disposed(by: disposeBag)
    
    rObservable
      .map { "\(Int(255 * $0))"}
      .bind(to: rLabel.rx.text)
      .disposed(by: disposeBag)
    
    gObservable
      .map { "\(Int(255 * $0))"}
      .bind(to: gLabel.rx.text)
      .disposed(by: disposeBag)
    
    bObservable
      .map { "\(Int(255 * $0))"}
      .bind(to: bLabel.rx.text)
      .disposed(by: disposeBag)
    
    let color = Observable<UIColor>.combineLatest(rObservable, gObservable, bObservable, resultSelector: { (rValue, gValue, bValue) -> UIColor in
      UIColor(red: rValue, green: gValue, blue: bValue, alpha: 1)
    })
    
    color
      .bind(to: colorView.rx.backgroundColor)
      .disposed(by: disposeBag)
    
    color.map { $0.hexString }
      .bind(to: hexColorTextField.rx.text)
      .disposed(by: disposeBag)
    
    applyButton.rx.tap.asObservable()
      .withLatestFrom(hexColorTextField.rx.text.orEmpty).map { (hexText: String) -> (Int, Int, Int)? in
        return hexText.rgb
      }.flatMap { (rgb) -> Observable<(Int, Int, Int)> in
        guard let rgb = rgb else { return Observable.empty() }
        
        return Observable.just(rgb)
      }.subscribe(onNext: { [weak self] (red, green, blue) in
        guard let `self` = self else { return }
        // ControlProperty: subscribe나 값을 넣을 수 있음
        self.rSlider.rx.value.onNext(Float(red) / 255.0)
        self.rSlider.sendActions(for: .valueChanged)
        
        self.gSlider.rx.value.onNext(Float(green) / 255.0)
        self.gSlider.sendActions(for: .valueChanged)
        
        self.bSlider.rx.value.onNext(Float(blue) / 255.0)
        self.bSlider.sendActions(for: .valueChanged)
      }).disposed(by: disposeBag)
  }
}

// ColorViewcontroller.create(parent: self): Observable<ColorViewController>
extension Reactive where Base: ColorViewController {
  var selectedColor: Observable<UIColor> {
    return base.doneButton.rx.tap.map { _ -> UIColor in
      return self.base.colorView.backgroundColor ?? UIColor.white
    }
  }
  
  static func create(parent: UIViewController?, animated: Bool = true) -> Observable<ColorViewController> {
    return Observable<ColorViewController>.create ({ (observer) -> Disposable in
      let colorViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ColorViewController") as! ColorViewController
      
      let dismissDisposable = colorViewController.cancelButton.rx.tap.asObservable()
        .subscribe(onNext: { [weak colorViewController] _ in
          guard let colorViewController = colorViewController else { return }
          colorViewController.dismiss(animated: animated, completion: nil)
        })
      
      // Navigation Controller 감싸서 사용해야 함
      let navigationController = UINavigationController(rootViewController: colorViewController)
      
      parent?.present(navigationController, animated: animated, completion: {
        observer.onNext(colorViewController)
      })
      
      // dismiss나 color 선택하고 나서 같이 취소시키고 싶음
      return Disposables.create([dismissDisposable, Disposables.create {
        colorViewController.dismiss(animated: animated, completion: nil)
        }])
    })
  }
  
  static func createToColor(parent: UIViewController?, animated: Bool = true) -> Observable<UIColor> {
    // 이벤트가 1개 발생하고 Observable가 dispose 되고나서 dismiss가 됨
    return self.create(parent: parent, animated: animated).flatMap { $0.rx.selectedColor }.take(1)
  }
}

// ColorViewcontroller.create(parent: self)  : Observable<ColorViewController>
extension Reactive where Base: UIView {
  var backgroundColor: Binder<UIColor> {
    return Binder(self.base) { (view, color) in
      view.backgroundColor = color
    }
  }
}

extension UIColor {
  var hexString: String {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return String(format: "%.2X%.2X%.2X", Int(255 * red), Int(255 * green), Int(255 * blue))
  }
}

extension String {
  var rgb: (Int, Int, Int)? {
    guard let number: Int = Int(self, radix: 16) else { return nil }
    let red = (number & 0xff0000) >> 16
    let green = (number & 0x00ff00) >> 8
    let blue = number & 0x0000ff
    return (red, green, blue)
  }
}
