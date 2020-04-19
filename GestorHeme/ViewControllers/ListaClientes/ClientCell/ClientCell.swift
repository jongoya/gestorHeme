//
//  ClientCellTableViewCell.swift
//  GestorHeme
//
//  Created by jon mikel on 01/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class ClientCell: UITableViewCell {
    @IBOutlet weak var contentCellView: UIView!
    @IBOutlet weak var imageCellView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    func setupCell(client: ClientModel) {
        nameLabel.text = "Nombre: " + client.nombre + " " + client.apellidos
        phoneLabel.text = "Telefono: " + client.telefono
    }
}
