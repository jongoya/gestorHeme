//
//  NotificationFunctions.swift
//  GestorHeme
//
//  Created by jon mikel on 09/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import Foundation

class NotificationFunctions: NSObject {
    
    static func checkBirthdays() {
        let birthdayClients: [ClientModel] = getTodayBirthdayClients()
        let todayNotifications: [NotificationModel] = getTodayNotifications()
        
        for client in birthdayClients {
            var notificationExist: Bool = false
            for notification in todayNotifications {
                if client.id == notification.clientId {
                    notificationExist = true
                }
            }
            
            if !notificationExist {
                createBirthdayNotification(client: client)
            }
        }
    }
    
    private static func getTodayBirthdayClients() -> [ClientModel] {
        let clients: [ClientModel] = Constants.databaseManager.clientsManager.getAllClientsFromDatabase()
        var birthdayClients: [ClientModel] = []
        
        for client in clients {
            let clientDay: Int = Calendar.current.component(.day, from: Date(timeIntervalSince1970: TimeInterval(client.fecha)))
            let clientMonth: Int = Calendar.current.component(.month, from: Date(timeIntervalSince1970: TimeInterval(client.fecha)))
            let todayDay: Int = Calendar.current.component(.day, from: Date())
            let todayMonth: Int = Calendar.current.component(.month, from: Date())
            
            if clientDay == todayDay && clientMonth == todayMonth {
                birthdayClients.append(client)
            }
        }
        
        return birthdayClients
    }
    
    private static func getTodayNotifications() -> [NotificationModel] {
        var todayNotifications: [NotificationModel] = []
        
        let notifications: [NotificationModel] = Constants.databaseManager.notificationsManager.getAllNotificationsFromDatabase()
        let begginingOfDay: Int64 = Int64(getBeginningOfDayFromDate(date: Date()).timeIntervalSince1970)
        let endOfDay: Int64 = Int64(getEndOfDayFromDate(date: Date()).timeIntervalSince1970)
        for notification in notifications {
            if notification.fecha > begginingOfDay && notification.fecha < endOfDay {
                todayNotifications.append(notification)
            }
        }
        
        return todayNotifications
    }
    
    static func getBeginningOfDayFromDate(date: Date) -> Date {
        let calendar: Calendar = Calendar.current
        var components: DateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        return calendar.date(from: components)!
    }
    
    static func getEndOfDayFromDate(date: Date) -> Date {
        let calendar: Calendar = Calendar.current
        var components: DateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        return calendar.date(from: components)!
    }
    
    static func createBirthdayNotification(client: ClientModel) {
        let notification: NotificationModel = NotificationModel()
        notification.notificationId = Int64(Date().timeIntervalSince1970)
        notification.fecha = Int64(Date().timeIntervalSince1970)
        notification.descripcion = "¡Hoy es el cumpleaños de " + client.nombre + " " + client.apellidos + ", manda felicitaciones sin falta!"
        notification.clientId = client.id
        notification.leido = false
        notification.type = Constants.notificacionCumpleIdentifier
        _ = Constants.databaseManager.notificationsManager.addNotificationToDatabase(newNotification: notification)
        
        Constants.cloudDatabaseManager.notificationManager.saveNotification(notification: notification)
    }
}
