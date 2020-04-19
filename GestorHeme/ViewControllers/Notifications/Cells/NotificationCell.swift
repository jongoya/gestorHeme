//
//  NotificationCell.swift
//  GestorHeme
//
//  Created by jon mikel on 09/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    @IBOutlet weak var notificationContentView: UIView!
    @IBOutlet weak var notificationImage: UIImageView!
    @IBOutlet weak var clientName: UILabel!
    @IBOutlet weak var notificationDescriptionLabel: UILabel!
    
    func setupCell(notification: NotificationModel) {
        let client: ClientModel =  Constants.databaseManager.clientsManager.getClientFromDatabase(clientId: notification.clientId)!
        
        customizeContentView(notification: notification)
        
        if notification.type == Constants.notificacionCumpleIdentifier {
            notificationImage.image = UIImage(named: "cumple")!.withRenderingMode(.alwaysTemplate)
            if notification.leido {
                notificationImage.tintColor = .black
            } else {
                notificationImage.tintColor = UIColor.link
            }
        }
        
        clientName.text = client.nombre + " " + client.apellidos
        notificationDescriptionLabel.text = notification.descripcion
    }
    
    private func customizeContentView(notification: NotificationModel) {
        notificationContentView.layer.cornerRadius = 10
        notificationContentView.layer.borderWidth = 1
        if notification.leido {
            notificationContentView.layer.borderColor = UIColor.systemGray4.cgColor
        } else {
            notificationContentView.layer.borderColor = UIColor.link.cgColor
        }
    }
}
