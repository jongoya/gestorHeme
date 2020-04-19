//
//  HemeTableViewCell.swift
//  GestorHeme
//
//  Created by jon mikel on 10/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class HemeTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var cellImageView: UIImageView!
    
    func setupCell(hemeModel: HemeModel) {
        cellContentView.layer.cornerRadius = 10
        titleLabel.text = hemeModel.titulo
        cellImageView.image = UIImage(named: hemeModel.nombreImagen)
    }
}
