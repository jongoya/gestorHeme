//
//  CloudNotificationManager.swift
//  GestorHeme
//
//  Created by jon mikel on 17/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import CloudKit

class CloudNotificationManager {
    let tableName: String = "CD_Notifications"
    
    let publicDatabase: CKDatabase = CKContainer.default().publicCloudDatabase
    let cloudDatabaseHelper: CloudDatabaseHelper = CloudDatabaseHelper()
    
    func getNotificaciones(delegate: CloudNotificationProtocol?) {
        var notificationIds: [Int64] = []
        let operation = CKQueryOperation(query: CKQuery(recordType: tableName, predicate: NSPredicate(value: true)))
        
        operation.recordFetchedBlock = { (record: CKRecord!) in
             if record != nil {
                let notification: NotificationModel = self.cloudDatabaseHelper.parseCloudNotificationsObjectToLocalNotificationObject(record: record)
                notificationIds.append(notification.notificationId)
                if Constants.databaseManager.notificationsManager.getNotificationFromDatabase(notificationId: notification.notificationId).count == 0 {
                    _ = Constants.databaseManager.notificationsManager.addNotificationToDatabase(newNotification: notification)
                } else {
                    _ = Constants.databaseManager.notificationsManager.markNotificationAsRead(notification: notification)
                }
            }
         }
        
        operation.queryCompletionBlock = {(cursor : CKQueryOperation.Cursor?, error : Error?) -> Void in
            self.checkNotificationsToRemove(cloudNotifications: notificationIds)
            DispatchQueue.main.async {
                delegate?.notificationsDownloaded()
            }
         }

        publicDatabase.add(operation)
    }
    
    private func checkNotificationsToRemove(cloudNotifications: [Int64]) {
        let localNotifications: [NotificationModel] = Constants.databaseManager.notificationsManager.getAllNotificationsFromDatabase()
        for notificationLocal: NotificationModel in localNotifications {
            if !cloudNotifications.contains(notificationLocal.notificationId) {
                _ = Constants.databaseManager.notificationsManager.eliminarNotificacion(notificationId: notificationLocal.notificationId)
            }
        }
    }
    
    func saveNotification(notification: NotificationModel) {
        CommonFunctions.showLoadingStateView(descriptionText: "Guardando notificación")
        
        let notificationRecord: CKRecord = CKRecord(recordType: tableName)
        cloudDatabaseHelper.setNotificationCKRecordVariables(notification: notification, record: notificationRecord)
        
        publicDatabase.save(notificationRecord) { (savedRecord, error) in
            CommonFunctions.hideLoadingStateView()
            if error != nil {
                CommonFunctions.showGenericAlertMessage(mensaje: "Error guardando la notificación, intentelo de nuevo", viewController: CommonFunctions.getRootViewController())
            }
        }
    }
    
    func updateNotification(notification: NotificationModel, showLoadingState: Bool) {
        if showLoadingState {
            CommonFunctions.showLoadingStateView(descriptionText: "Guardando notificación")
        }
        
        let predicate = NSPredicate(format: "CD_notificationId = %d", notification.notificationId)
        let query = CKQuery(recordType: tableName, predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil  || results!.count == 0 {
                CommonFunctions.hideLoadingStateView()
                CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando la notificación, intentelo de nuevo", viewController: CommonFunctions.getRootViewController())
                return
            }
            
            self.cloudDatabaseHelper.setNotificationCKRecordVariables(notification: notification, record: results!.first!)
            
            self.publicDatabase.save(results!.first!, completionHandler: { (newRecord, error) in
                CommonFunctions.hideLoadingStateView()
                if error != nil {
                    CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando la notificación, intentelo de nuevo", viewController: CommonFunctions.getRootViewController())
                }
                
            })
        }
    }
    
    func deleteNotification(notificationId: Int64) {
        let predicate = NSPredicate(format: "CD_notificationId = %d", notificationId)
        let query = CKQuery(recordType: tableName, predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil  || results!.count == 0 {
                return
            }
            
            self.publicDatabase.delete(withRecordID: results!.first!.recordID) {result, error in
            }
        }
    }
    

    
    func deleteOldNotifications() {
        let fechaTimeStamp: Int64 = Int64(Calendar.current.date(byAdding: .day, value: -8, to: Date())!.timeIntervalSince1970)
        let predicate = NSPredicate(format: "CD_fecha < %d", fechaTimeStamp)
        let query = CKQuery(recordType: tableName, predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil  || results!.count == 0 {
                return
            }
            
            for record in results! {
                self.publicDatabase.delete(withRecordID: record.recordID) {result, error in
                }
            }
        }
    }
}
