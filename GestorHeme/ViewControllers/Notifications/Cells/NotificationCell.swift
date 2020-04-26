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
        customizeContentView(notification: notification)
        
        if notification.type == Constants.notificacionCumpleIdentifier {
            setBirthdayContent(notification: notification)
        } else if notification.type == Constants.notificacionCajaCierreIdentifier {
            setCierreCajaContent(notification: notification)
        } else if notification.type == Constants.notificacionCadenciaIdentifier {
            setCadenciacontent(notification: notification)
        } else if notification.type == Constants.notificacionPersonalizadaIdentifier {
            setPersonalizadaContent(notification: notification)
        }
    }
    
    private func customizeContentView(notification: NotificationModel) {
        notificationContentView.layer.cornerRadius = 10
        notificationContentView.layer.borderWidth = 1
        if notification.leido {
            notificationImage.tintColor = .black
            notificationContentView.layer.borderColor = UIColor.systemGray4.cgColor
        } else {
            notificationContentView.layer.borderColor = UIColor.link.cgColor
            notificationImage.tintColor = UIColor.link
        }
    }
    
    private func setBirthdayContent(notification: NotificationModel) {
        notificationImage.image = UIImage(named: "cumple")!.withRenderingMode(.alwaysTemplate)
        clientName.text = "¡Felicitaciones!"
        
        let nextText: String = notification.clientId.count > 1 ? " personas, felicitalos!" : " persona, felicitalo!"
        notificationDescriptionLabel.text = "¡Hoy cumplen años " + String(notification.clientId.count) +  nextText
    }
    
    private func setCierreCajaContent(notification: NotificationModel) {
        notificationImage.image = UIImage(named: "cash")!.withRenderingMode(.alwaysTemplate)
        
        let year: Int = AgendaFunctions.getYearNumberFromDate(date: Date(timeIntervalSince1970: TimeInterval(notification.fecha)))
        let month: String = AgendaFunctions.getMonthNameFromDate(date: Date(timeIntervalSince1970: TimeInterval(notification.fecha))).capitalized
        let day: Int = Calendar.current.component(.day, from: Date(timeIntervalSince1970: TimeInterval(notification.fecha)))
        
        clientName.text = String(day) + " de " + String(month) + " de " + String(year)
        notificationDescriptionLabel.text = "¡El cierre de caja está pendiente de realizar!"
    }
    
    private func setCadenciacontent(notification: NotificationModel) {
        notificationImage.image = UIImage(named: "cadencia")!.withRenderingMode(.alwaysTemplate)
        clientName.text = "¡Cadencia!"
        
        var text: String = String(notification.clientId.count)
        text.append(notification.clientId.count > 1 ? " clientes llevan tiempo sin venir" : " cliente lleva tiempo sin venir")
        
        notificationDescriptionLabel.text = text
    }
    
    private func setPersonalizadaContent(notification: NotificationModel) {
        notificationImage.image = UIImage(named: "campana")!.withRenderingMode(.alwaysTemplate)
        let cliente: ClientModel = Constants.databaseManager.clientsManager.getClientFromDatabase(clientId: notification.clientId.first!)!
        
        let year: Int = AgendaFunctions.getYearNumberFromDate(date: Date(timeIntervalSince1970: TimeInterval(notification.fecha)))
        let month: String = AgendaFunctions.getMonthNameFromDate(date: Date(timeIntervalSince1970: TimeInterval(notification.fecha))).capitalized
        let day: Int = Calendar.current.component(.day, from: Date(timeIntervalSince1970: TimeInterval(notification.fecha)))
        
        clientName.text = String(day) + " de " + String(month) + " de " + String(year)
        notificationDescriptionLabel.text = "Notificación de " + cliente.nombre + " " + cliente.apellidos
    }
}
