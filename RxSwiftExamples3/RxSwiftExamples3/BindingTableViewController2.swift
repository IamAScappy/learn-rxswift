//
//  BindingTableView2Controller.swift
//  RxSwiftExamples3
//
//  Created by yuaming on 2018. 8. 4..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa

class BindingTableViewController2: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  
  private let dataSource = BehaviorRelay<[NameModel]>(value: [
      NameModel(name: "강현정", number: 1),
      NameModel(name: "박세종", number: 2),
      NameModel(name: "웅", number: 3),
      NameModel(name: "감자", number: 4),
    ]
  )
  
  private var disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
  }
}

extension BindingTableViewController2 {
  private func bind() {
    dataSource
      .bind(to: tableView.rx.items(cellIdentifier: "NameCell", cellType: NameCell.self)) { (index, model, cell) in
        cell.load(with: model)
      }.disposed(by: disposeBag)
    
    tableView.rx.itemSelected.asObservable().withLatestFrom(dataSource) { (indexPath, dataSource) -> NameModel in
        return dataSource[indexPath.row]
      }.flatMap { [weak self] nameModel -> Observable<NameModel> in
        return Observable.create({ (observer) -> Disposable in
          let alert = UIAlertController.init(title: "선택", message: nameModel.name, preferredStyle: .alert)
          
          alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            observer.onNext(nameModel)
            observer.onCompleted()
          }))
          
          alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { _ in
            observer.onCompleted()
          }))
          
          self?.present(alert, animated: true, completion: nil)
          
          return Disposables.create { }
        })
      }.subscribe(onNext: { [weak self] (model) in
        guard let `self` = self else { return }
        let dataSource = self.dataSource.value.filter { (element) -> Bool in
          element.name != model.name && element.number != model.number
        }
        self.dataSource.accept(dataSource)
      }).disposed(by: disposeBag)
  }
}
