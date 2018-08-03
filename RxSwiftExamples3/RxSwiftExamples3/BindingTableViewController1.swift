//
//  BindingTableView1Controller.swift
//  RxSwiftExamples3
//
//  Created by yuaming on 2018. 8. 4..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class BindingTableViewController1: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  
  private let dataSource = [
    NameModel(name: "강현정", number: 1),
    NameModel(name: "박세종", number: 2),
    NameModel(name: "웅", number: 3),
    NameModel(name: "감자", number: 4),
  ]
  
  private var disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
  }
}

extension BindingTableViewController1 {
  private func bind() {
    Observable<[NameModel]>.just(dataSource)
      .bind(to: tableView.rx.items) { (tableView, index, model) -> UITableViewCell in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NameCell") as? NameCell else {
          return UITableViewCell()
        }
        
        cell.load(with: model)        
        return cell
      }.disposed(by: disposeBag)
  }
}
