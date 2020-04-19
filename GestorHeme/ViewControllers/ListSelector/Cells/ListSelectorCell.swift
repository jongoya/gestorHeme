//
//  ListSelectorCell.swift
//  GestorHeme
//
//  Created by jon mikel on 02/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class ListSelectorCell: UITableViewCell {
    @IBOutlet weak var optionTextLabel: UILabel!

    func setupCell(option: String) {
        optionTextLabel.text = option
    }
}
