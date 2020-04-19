//
//  ServicioTableViewCell.swift
//  GestorHeme
//
//  Created by jon mikel on 13/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class ServicioTableViewCell: UITableViewCell {
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var nombreServicioLabel: UILabel!
    
    func setupCell(servicio: TipoServicioModel) {
        cellContentView.layer.cornerRadius = 10
        nombreServicioLabel.text = servicio.nombre
    }
}
