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
        let birthdayUsers: [BirthdayModel] = getTodayBirthdayUsers()
        let todayNotifications: [NotificationModel] = getTodayNotifications()
        var todayBirthdayUsers: [BirthdayModel] = []
        
        if birthdayUsers.count == 0 {
            return
        }
        
        for user in birthdayUsers {
            var notificationExists = false
            for notification in todayNotifications {
                if notification.clientId.contains(user.userId) {
                    notificationExists = true
                }
            }
            
            if !notificationExists {
                todayBirthdayUsers.append(user)
            }
        }
        
        if todayBirthdayUsers.count > 0 {
            createBirthdayNotification(users: todayBirthdayUsers)
        }
    }
    
    private static func getTodayBirthdayUsers() -> [BirthdayModel] {
        let clients: [ClientModel] = Constants.databaseManager.clientsManager.getAllClientsFromDatabase()
        let empleados: [EmpleadoModel] = Constants.databaseManager.empleadosManager.getAllEmpleadosFromDatabase()
        var birthdayUsers: [BirthdayModel] = []
        let todayDay: Int = Calendar.current.component(.day, from: Date())
        let todayMonth: Int = Calendar.current.component(.month, from: Date())
        
        for client in clients {
            let clientDay: Int = Calendar.current.component(.day, from: Date(timeIntervalSince1970: TimeInterval(client.fecha)))
            let clientMonth: Int = Calendar.current.component(.month, from: Date(timeIntervalSince1970: TimeInterval(client.fecha)))
            
            if clientDay == todayDay && clientMonth == todayMonth {
                birthdayUsers.append(BirthdayModel(userId: client.id, nombre: client.nombre, apellidos: client.apellidos))
            }
        }
        
        for empleado in empleados {
            let empleadoDay: Int = Calendar.current.component(.day, from: Date(timeIntervalSince1970: TimeInterval(empleado.fecha)))
            let empleadoMonth: Int = Calendar.current.component(.month, from: Date(timeIntervalSince1970: TimeInterval(empleado.fecha)))
            if empleadoDay == todayDay && empleadoMonth == todayMonth {
                birthdayUsers.append(BirthdayModel(userId: empleado.empleadoId, nombre: empleado.nombre, apellidos: empleado.apellidos))
            }
        }
        
        return birthdayUsers
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
    
    static func createBirthdayNotification(users: [BirthdayModel]) {
        let notification: NotificationModel = NotificationModel()
        notification.notificationId = Int64(Date().timeIntervalSince1970)
        notification.fecha = Int64(Date().timeIntervalSince1970)
        notification.clientId = getUserIdsFromBirthdayModels(users: users)
        notification.leido = false
        notification.type = Constants.notificacionCumpleIdentifier
        _ = Constants.databaseManager.notificationsManager.addNotificationToDatabase(newNotification: notification)
        
        Constants.cloudDatabaseManager.notificationManager.saveNotification(notification: notification)
    }
    
    private static func getUserIdsFromBirthdayModels(users: [BirthdayModel]) -> [Int64] {
        var userIds: [Int64] = []
        for user in users {
            userIds.append(user.userId)
        }
        
        return userIds
    }
}
