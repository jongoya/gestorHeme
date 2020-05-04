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
        nameLabel.text = client.apellidos + ", " + client.nombre
        phoneLabel.text = "Telefono: " + client.telefono
        
        if client.imagen.count > 0 {
            let dataDecoded : Data = Data(base64Encoded: client.imagen, options: .ignoreUnknownCharacters)!
            imageCellView.image = UIImage(data: dataDecoded)
            imageCellView.layer.cornerRadius = 30
            imageCellView.contentMode = .scaleAspectFill
        } else {
            imageCellView.image = UIImage(named: "user_placeholder")
            imageCellView.layer.cornerRadius = 0
            imageCellView.contentMode = .scaleAspectFit
        }
    }
}
