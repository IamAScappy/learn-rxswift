//
//  GroupListViewController.swift
//  RxSwiftExamples2
//
//  Created by yuaming on 26/07/2018.
//  Copyright © 2018 yuaming. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class GroupListViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  
  fileprivate let disposeBag: DisposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
  }
}

typealias GroupSection = SectionModel<String, Group>

extension GroupListViewController {
  fileprivate func createDatasource() -> RxTableViewSectionedReloadDataSource<GroupSection> {
    return RxTableViewSectionedReloadDataSource<GroupSection>(configureCell: { (datasource, tableView, indexPath, group) -> UITableViewCell in
      let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
      cell.textLabel?.text = group.name
      return cell
    }, titleForHeaderInSection: { (datasource, index) -> String? in
      return datasource.sectionModels[index].model
    })
  }
  
  fileprivate func bind() {
    // zip이 아니여도 combineLatest로도 상관없지만, 지금 상황에서 API 호출이 1번 이기 때문에 combineLatest가 적절하지 않음
    let items: Observable<[GroupSection]> = Observable.zip(GroupListAPI.groupList(), GroupListAPI.categoryList()) { (groups: [Group], categories: [Category]) -> [GroupSection] in
      return categories.map { category -> GroupSection in
        let categoryGroups = groups.filter { $0.categoryID == category.ID }
        return GroupSection(model: category.name, items: categoryGroups)
      }
    }
    
    // 어떤 방식으로 바인딩 할 것인가? DataSource를 이용할 것인가?
    items.bind(to: tableView.rx.items(dataSource: createDatasource())).disposed(by: disposeBag)
  }
}

struct Group {
  let name: String
  let categoryID: Int
  let ID: Int
}

struct Category {
  let name: String
  let ID: Int
  let groups: [Int]
}

struct GroupListAPI {
  static func groupList() -> Observable<[Group]> {
    let groupList: [Group] =
      [Group(name: "첫번째 그룹", categoryID: 1, ID: 1),
       Group(name: "두번째 그룹", categoryID: 1, ID: 2),
       Group(name: "세번째 그룹", categoryID: 1, ID: 3),
       Group(name: "네번째 그룹", categoryID: 2, ID: 4),
       Group(name: "다섯번째 그룹", categoryID: 2, ID: 5),
       Group(name: "여섯번째 그룹", categoryID: 2, ID: 6),
       Group(name: "일곱번째 그룹", categoryID: 2, ID: 7),
       Group(name: "여덟번째 그룹", categoryID: 3, ID: 8),
       Group(name: "아홉번째 그룹", categoryID: 3, ID: 9),
       Group(name: "열번째 그룹", categoryID: 3, ID: 10),
       Group(name: "열한번째 그룹", categoryID: 3, ID: 11),
       Group(name: "열두번째 그룹", categoryID: 4, ID: 12),
       Group(name: "열세번째 그룹", categoryID: 4, ID: 13)]
    
    // delay: 이벤트가 2개 일어난다면 0.5초 후에 일어남
    return Observable.just(groupList).delay(0.5, scheduler: MainScheduler.instance)
  }
  
  static func categoryList() -> Observable<[Category]> {
    let categoryList: [Category] =
      [Category(name: "첫번째 카테고리", ID: 1, groups: [1,2,3]),
       Category(name: "두번째 카테고리", ID: 2, groups: [4,5,6,7]),
       Category(name: "세번째 카테고리", ID: 3, groups: [8,9,10,11]),
       Category(name: "네번째 카테고리", ID: 4, groups: [12,13])]
    return Observable.just(categoryList).delay(0.7, scheduler: MainScheduler.instance)
  }
}
