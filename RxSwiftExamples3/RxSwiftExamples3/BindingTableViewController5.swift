//
//  BindingTableViewController5.swift
//  RxSwiftExamples3
//
//  Created by yuaming on 2018. 8. 4..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa

class BindingTableViewController5: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var mixedButton: UIBarButtonItem!
  
  private var disposeBag = DisposeBag()
  private let dataSource = [
    NameModel(name: "강현정", number: 1),
    NameModel(name: "박세종", number: 2),
    NameModel(name: "웅", number: 3),
    NameModel(name: "감자", number: 4)
  ]
  
  private let secondDataSource = [
    NameModel(name: "감자", number: 4),
    NameModel(name: "웅", number: 3),
    NameModel(name: "박세종", number: 2),
    NameModel(name: "뭉", number: 5),
    NameModel(name: "강현정", number: 1)
  ]
  
  private var dataSources = BehaviorRelay<[NameModel]>(value: [])
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.isEditing = true
    bind()
  }
}

extension BindingTableViewController5 {
  typealias SectionModel = AnimatableSectionModel<String, NameModel>
  typealias SectionDataSource = RxTableViewSectionedAnimatedDataSource<SectionModel>
  
  private func bind() {
    dataSources.accept(dataSource)
    
    dataSources.map { models in
        return [SectionModel(model: "", items: models)]
      }
      .bind(to: tableView.rx.items(dataSource: configureDataSource()))
      .disposed(by: disposeBag)
    
    mixedButton.rx.tap.map { [weak self] _ in
        return self?.secondDataSource ?? []
      }
      .bind(to: dataSources).disposed(by: disposeBag)
  }
  
  private func configureDataSource() -> SectionDataSource {
    let dataSources = SectionDataSource(
        animationConfiguration: AnimationConfiguration(insertAnimation: .automatic, reloadAnimation: .fade, deleteAnimation: .right),
        configureCell: { (dataSource, tableView, indexPath, model) -> UITableViewCell in
          guard let cell = tableView.dequeueReusableCell(withIdentifier: "NameCell") as? NameCell else {
            return UITableViewCell()
          }
      
          cell.load(with: model)
          return cell
      }, titleForHeaderInSection: { (dataSource, index) -> String? in
        return "Header"
      }, titleForFooterInSection: { (dataSource, index) -> String? in
        return "Footer"
      }, canEditRowAtIndexPath: { (dataSource, indexPath) -> Bool in
        return indexPath.row % 2 == 0
      }, canMoveRowAtIndexPath: { (dataSource, indexPath) -> Bool in
        return indexPath.row % 2 == 1
      }, sectionIndexTitles: { (dataSource) -> [String]? in
        return nil
      }) { (_, _, _) -> Int in
        return 0
      }
    
    return dataSources
  }
}
