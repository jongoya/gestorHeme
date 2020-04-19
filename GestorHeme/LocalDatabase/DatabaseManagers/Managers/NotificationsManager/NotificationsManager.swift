//
//  NotificationsManager.swift
//  GestorHeme
//
//  Created by jon mikel on 09/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import CoreData


class NotificationsManager: NSObject {
    let NOTIFICATIONS_ENTITY_NAME: String = "Notifications"
    var databaseHelper: DatabaseHelper!
    
    var backgroundContext: NSManagedObjectContext!//para escritura
    var mainContext: NSManagedObjectContext!//para lectura
    
    override init() {
        super.init()
        let app = UIApplication.shared.delegate as! AppDelegate
        backgroundContext = app.persistentContainer.newBackgroundContext()
        mainContext = app.persistentContainer.viewContext
        databaseHelper = DatabaseHelper()
    }
    
    func getAllNotificationsFromDatabase() -> [NotificationModel] {
        var notifications: [NotificationModel] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: NOTIFICATIONS_ENTITY_NAME)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results: [NSManagedObject] = try mainContext.fetch(fetchRequest)
            for data in results {
                notifications.append(databaseHelper.parseNotificationCoreObjectToNotificationModel(coreObject: data))
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return notifications
    }
    
    func addNotificationToDatabase(newNotification: NotificationModel) -> Bool {
        let entity = NSEntityDescription.entity(forEntityName: NOTIFICATIONS_ENTITY_NAME, in: backgroundContext)
        
        if getNotificationFromDatabase(notificationId: newNotification.notificationId).count == 0 {
            let coreService = NSManagedObject(entity: entity!, insertInto: backgroundContext)
            databaseHelper.setCoreDataObjectDataFromNotification(coreDataObject: coreService, newNotification: newNotification)
            do {
                try backgroundContext.save()
                return true
            } catch {
                return false
            }
        } else {
            return false
        }
    }
    
    func getNotificationFromDatabase(notificationId: Int64) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: NOTIFICATIONS_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "notificationId = %f", argumentArray: [notificationId])
        var results: [NSManagedObject] = []
        
        do {
            results = try mainContext.fetch(fetchRequest)
        } catch {
            print("Error checking the client in database")
        }
        
        return results
    }
    
    func markNotificationAsRead(notification: NotificationModel) -> Bool {
        let notifications: [NSManagedObject] = getNotificationFromDatabase(notificationId: notification.notificationId)
        
        if notifications.count == 0 {
            return false
        }
        
        let coreNotification: NSManagedObject = notifications.first!
        coreNotification.setValue(notification.leido, forKey: "leido")
        
        do {
            try mainContext.save()
            return true
        } catch {
            return false
        }
    }
}
