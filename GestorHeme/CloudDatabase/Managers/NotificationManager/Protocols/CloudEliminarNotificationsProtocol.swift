//
//  CloudCadenciaNotificationProtocol.swift
//  GestorHeme
//
//  Created by jon mikel on 30/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import Foundation

protocol CloudEliminarNotificationsProtocol {
    func succesDeletingNotification(notifications: [NotificationModel])
    func errorDeletingNotifications(error: String)
}
