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
    let notificacionesQuery: CKQuery = CKQuery(recordType: "CD_Notifications", predicate: NSPredicate(value: true))
    let notificationRecord: CKRecord = CKRecord(recordType: "CD_Notifications")
    let publicDatabase: CKDatabase = CKContainer.default().publicCloudDatabase
    let cloudDatabaseHelper: CloudDatabaseHelper = CloudDatabaseHelper()
    
    func getNotificaciones() {
        let operation = CKQueryOperation(query: notificacionesQuery)
        operation.recordFetchedBlock = { (record: CKRecord!) in
             if record != nil{
                let notification: NotificationModel = self.cloudDatabaseHelper.parseCloudNotificationsObjectToLocalNotificationObject(record: record)
                
                if Constants.databaseManager.notificationsManager.getNotificationFromDatabase(notificationId: notification.notificationId).count == 0 {
                    _ = Constants.databaseManager.notificationsManager.addNotificationToDatabase(newNotification: notification)
                } else {
                    _ = Constants.databaseManager.notificationsManager.markNotificationAsRead(notification: notification)
                }
             }
         }
        
        operation.queryCompletionBlock = { [weak self] (cursor : CKQueryOperation.Cursor?, error : Error?) -> Void in
             if cursor != nil {
                let newOperation = CKQueryOperation(cursor: cursor!)
                newOperation.recordFetchedBlock = operation.recordFetchedBlock
                newOperation.queryCompletionBlock = operation.queryCompletionBlock
                self!.publicDatabase.add(newOperation)
             }
         }

        publicDatabase.add(operation)
    }
    
    func saveNotification(notification: NotificationModel) {
        CommonFunctions.showLoadingStateView(descriptionText: "Guardando notificación")
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
        let query = CKQuery(recordType: "CD_Notifications", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil  || results!.count == 0 {
                CommonFunctions.hideLoadingStateView()
                CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando la notificación, intentelo de nuevo", viewController: CommonFunctions.getRootViewController())
                return
            }
            
            let recordToUpdate: CKRecord! = results!.first!
            self.cloudDatabaseHelper.setNotificationCKRecordVariables(notification: notification, record: recordToUpdate)
            
            self.publicDatabase.save(recordToUpdate, completionHandler: { (newRecord, error) in
                CommonFunctions.hideLoadingStateView()
                if error != nil {
                    CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando la notificación, intentelo de nuevo", viewController: CommonFunctions.getRootViewController())
                }
                
            })
        }
    }
    
    func deleteNotification(notificationId: Int64) {
        let predicate = NSPredicate(format: "CD_notificationId = %d", notificationId)
        let query = CKQuery(recordType: "CD_Notifications", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil  || results!.count == 0 {
                return
            }
            
            let recordToDelete: CKRecord! = results!.first!
            self.publicDatabase.delete(withRecordID: recordToDelete.recordID) {result, error in
            }
        }
    }
}
