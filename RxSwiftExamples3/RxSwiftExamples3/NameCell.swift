//
//  NameCell.swift
//  RxSwiftExamples3
//
//  Created by yuaming on 2018. 8. 4..
//  Copyright © 2018년 yuaming. All rights reserved.
//

import UIKit

class NameCell: UITableViewCell {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var numberLabel: UILabel!
  
  override func prepareForReuse() {
    nameLabel.text = nil
    numberLabel.text = nil
  }
  
  func load(with model: NameModel) {
    nameLabel.text = model.name
    numberLabel.text = "\(model.number)"
  }
}
