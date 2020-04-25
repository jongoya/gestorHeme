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
        
        mainContext.performAndWait {
            do {
                let results: [NSManagedObject] = try mainContext.fetch(fetchRequest)
                for data in results {
                    notifications.append(databaseHelper.parseNotificationCoreObjectToNotificationModel(coreObject: data))
                }
            } catch {
            }
        }

        return notifications
    }
    
    func addNotificationToDatabase(newNotification: NotificationModel) -> Bool {
        let entity = NSEntityDescription.entity(forEntityName: NOTIFICATIONS_ENTITY_NAME, in: backgroundContext)
        
        if getNotificationFromDatabase(notificationId: newNotification.notificationId).count == 0 {
            let coreService = NSManagedObject(entity: entity!, insertInto: backgroundContext)
            databaseHelper.setCoreDataObjectDataFromNotification(coreDataObject: coreService, newNotification: newNotification)
            
            var result: Bool = false
            backgroundContext.performAndWait {
                do {
                    try backgroundContext.save()
                    result = true
                } catch {
                    print("")
                }
            }
            
            return result
        } else {
            return false
        }
    }
    
    func getNotificationFromDatabase(notificationId: Int64) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: NOTIFICATIONS_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "notificationId = %f", argumentArray: [notificationId])
        var results: [NSManagedObject] = []
        
        mainContext.performAndWait {
            do {
                results = try mainContext.fetch(fetchRequest)
            } catch {
            }
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
        
        var result: Bool = false
        mainContext.performAndWait {
            do {
                try mainContext.save()
                result = true
            } catch {
                print("Error actualizando notificación")
            }
        }
        
        return result
    }
    
    func removeClientFromNotification(clientId: Int64, notificationType: String) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: NOTIFICATIONS_ENTITY_NAME)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "type = %@", argumentArray: [notificationType])

        mainContext.performAndWait {
            do {
                let results: [NSManagedObject] = try mainContext.fetch(fetchRequest)
                for data in results {
                    let clientIds: [Int64] = data.value(forKey: "clientId") as! [Int64]
                    if clientIds.contains(clientId) {
                        let filters = clientIds.filter {$0 != clientId}
                        data.setValue(filters, forKey: "clientId")
                        let notification: NotificationModel = databaseHelper.parseNotificationCoreObjectToNotificationModel(coreObject: data)
                        if filters.count == 0 {
                            mainContext.delete(data)
                            Constants.cloudDatabaseManager.notificationManager.deleteNotification(notificationId: notification.notificationId)
                        } else {
                            Constants.cloudDatabaseManager.notificationManager.updateNotification(notification: notification, showLoadingState: false)
                        }
                    }
                }
                
                try mainContext.save()
            } catch {
            }
        }
    }
    
    func getAllNotificationsForType(type: String) -> [NotificationModel] {
        var notifications: [NotificationModel] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: NOTIFICATIONS_ENTITY_NAME)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "type = %@", argumentArray: [type])

        mainContext.performAndWait {
            do {
                let results: [NSManagedObject] = try mainContext.fetch(fetchRequest)
                for data in results {
                    notifications.append(databaseHelper.parseNotificationCoreObjectToNotificationModel(coreObject: data))
                }
            } catch {
            }
        }

        return notifications
    }
}
