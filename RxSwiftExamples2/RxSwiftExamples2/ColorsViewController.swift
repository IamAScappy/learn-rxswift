//
//  ColorsViewController.swift
//  RxSwiftExamples2
//
//  Created by yuaming on 27/07/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ColorsViewController: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var addButton: UIBarButtonItem!
  
  fileprivate let refreshControl = UIRefreshControl()
  fileprivate var dataSource: BehaviorRelay<[UIColor]> = BehaviorRelay(value: [UIColor.cyan, UIColor.magenta, UIColor.orange])
  fileprivate var disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.refreshControl = refreshControl
    
    bind()
  }
}

extension ColorsViewController {
  fileprivate func bind() {
    refreshControl.rx.controlEvent(.valueChanged)
      .subscribe(onNext: {[weak self] _ in
        guard let `self` = self else { return }
        self.refreshControl.endRefreshing()
        
        var dataSource = self.dataSource.value
        dataSource.reverse()
        
        self.dataSource.accept(dataSource)
      }).disposed(by: disposeBag)
    
    addButton.rx.tap.flatMap { [weak self] in
      return ColorViewController.rx.createToColor(parent: self)
    }.subscribe(onNext: { [weak self] color in
      guard let `self` = self else { return }
      
      var dataSource = self.dataSource.value
      dataSource.append(color)
      self.dataSource.accept(dataSource)
    }).disposed(by: disposeBag)
    
    dataSource
      .map { [Section(model: "", items: $0)] }
      .bind(to: collectionView.rx.items(dataSource: createDataSource()))
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected.asObservable().subscribe(onNext: { [weak self] (indexPath) in
      guard let `self` = self else { return }
      var dataSource = self.dataSource.value
      dataSource.remove(at: indexPath.item)
      self.dataSource.accept(dataSource)
    }).disposed(by: disposeBag)
  }
  
  typealias Section = AnimatableSectionModel<String, UIColor>
  typealias ColorDataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
  
  func createDataSource() -> ColorDataSource {
    let dataSource = ColorDataSource(configureCell: { (dataSource, collectionView, indexPath, color) -> UICollectionViewCell in
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
      cell.contentView.backgroundColor = color
      return cell
    }, configureSupplementaryView: { (dataSource, collectionView, kind, indexPath) -> UICollectionReusableView in
      return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "", for: indexPath)
    })
   
    return dataSource
  }
}

extension UIColor: IdentifiableType {
  public var identity: Int {
    return self.cgColor.hashValue
  }
}
