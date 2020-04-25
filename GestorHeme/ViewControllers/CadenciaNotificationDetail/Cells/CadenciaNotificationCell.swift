//
//  CadenciaNotificationCell.swift
//  GestorHeme
//
//  Created by jon mikel on 25/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class CadenciaNotificationCell: UITableViewCell {
    @IBOutlet weak var clientText: UILabel!
    
    func setupCell(client: ClientModel) {
        clientText.text = client.nombre + " " + client.apellidos
    }
}
