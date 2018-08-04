//
//  BindingTableViewController6.swift
//  RxSwiftExamples3
//
//  Created by yuaming on 2018. 8. 4..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import UIKit

class BindingTableViewController6: UIViewController {
  @IBOutlet weak var editButton: UIBarButtonItem!
  @IBOutlet weak var addButton: UIBarButtonItem!
  @IBOutlet weak var tableView: UITableView!
  
  private var disposeBag = DisposeBag()
  private let dataSources = BehaviorRelay<[String]>(value: ["강현정", "박세종", "웅", "감자"])
  
  typealias NameSectionModel = AnimatableSectionModel<String, String>
  typealias NameDataSource = RxTableViewSectionedAnimatedDataSource<NameSectionModel>
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
  }
}

private extension BindingTableViewController6 {
  func bind() {
    addButton.rx.tap.flatMap { [weak self] _ -> Observable<String> in
      guard let `self` = self else { return Observable.empty() }
      return self.alert(title: "추가", message: "이름을 입력하세요")
    }.subscribe(onNext: { [weak self] name in
      guard let `self` = self else { return }
      var names = self.dataSources.value
      names.append(name)
      self.dataSources.accept(names)
    }).disposed(by: disposeBag)
    
    dataSources.map {
      [NameSectionModel(model: "", items: $0)]
    }
    .bind(to: tableView.rx.items(dataSource: configureDataSource()))
    .disposed(by: disposeBag)
    
    tableView.rx.itemSelected.withLatestFrom(dataSources) { (indexPath, names) -> (IndexPath, String) in
      return (indexPath, names[indexPath.row])
    }.flatMap { [weak self] (indexPath, name) -> Observable<(IndexPath, String)> in
        guard let `self` = self else { return Observable.empty() }
        return self.alert(title: "변경", message: "변경할 이름을 입력하세요", indexPath: indexPath, inputText: name)
    }.subscribe(onNext: { [weak self] (indexPath, name) in
      guard let `self` = self else { return }
      var names = self.dataSources.value
      names[indexPath.row] = name
      self.dataSources.accept(names)
    }).disposed(by: disposeBag)
    editButton.rx.tap.subscribe(onNext: { [weak self] _ in
      guard let `self` = self else { return }
      self.tableView.setEditing(!self.tableView.isEditing, animated: true)
    }).disposed(by: disposeBag)
    
    tableView.rx.itemDeleted
      .subscribe(onNext: { [weak self] indexPath in
        guard let `self` = self else { return }
        var names = self.dataSources.value
        names.remove(at: indexPath.row)
        self.dataSources.accept(names)
      }).disposed(by: disposeBag)
    
    tableView.rx.itemMoved
      .subscribe(onNext: { [weak self] (sourceIndexPath, destinationIndexPath) in
        guard let `self` = self else { return }
        var names = self.dataSources.value
        let source = names[sourceIndexPath.row]
        names[sourceIndexPath.row] = names[destinationIndexPath.row]
        names[destinationIndexPath.row] = source
        self.dataSources.accept(names)
      }).disposed(by: disposeBag)
  }
  
  func configureDataSource() -> NameDataSource {
    return NameDataSource(configureCell: { (dataSource, tableView, indexPath, model) -> UITableViewCell in
      let cell = tableView.dequeueReusableCell(withIdentifier: "NameCell", for: indexPath)
      cell.textLabel?.text = model
      return cell
    }, canEditRowAtIndexPath: { (dataSource, indexPath) -> Bool in
      return true
    }, canMoveRowAtIndexPath: { (dataSource, indexPaht) -> Bool in
      return true
    })
  }
  
  func alert(title: String? , message: String?) -> Observable<String> {
    return Observable<String>.create{ [weak self] (observer) -> Disposable in
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alert.addTextField(configurationHandler: nil)
      
      alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
        let text: String = alert.textFields?[0].text ?? ""
        observer.onNext(text)
        observer.onCompleted()
      }))
      
      alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
      
      self?.present(alert, animated: true, completion: nil)
      return Disposables.create { }
    }
  }
  
  func alert(title: String? , message: String?, indexPath: IndexPath, inputText: String) -> Observable<(IndexPath, String)> {
    return Observable<(IndexPath, String)>.create{ [weak self] (observer) -> Disposable in
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alert.addTextField(configurationHandler: { (textField) in
        textField.text = inputText
      })
      
      alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
        let text: String = alert.textFields?[0].text ?? ""
        observer.onNext( (indexPath, text) )
        observer.onCompleted()
      }))
      
      alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
      
      self?.present(alert, animated: true, completion: nil)
      return Disposables.create { }
    }
  }
}
