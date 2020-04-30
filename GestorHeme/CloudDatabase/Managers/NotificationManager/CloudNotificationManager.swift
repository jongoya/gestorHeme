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
    var notificationIds: [Int64] = []
    var contadorNotificaciones: Int = 0
    
    func getNotificaciones(delegate: CloudNotificationProtocol?) {
        let operation = CKQueryOperation(query: CKQuery(recordType: tableName, predicate: NSPredicate(value: true)))
        executeGetNotificacionesOperation(operation: operation, delegate: delegate)
    }
    
    private func executeGetNotificacionesOperation(operation: CKQueryOperation, delegate: CloudNotificationProtocol?) {
        operation.recordFetchedBlock = { (record: CKRecord!) in
             if record != nil {
                let notification: NotificationModel = self.cloudDatabaseHelper.parseCloudNotificationsObjectToLocalNotificationObject(record: record)
                self.notificationIds.append(notification.notificationId)
                if Constants.databaseManager.notificationsManager.getNotificationFromDatabase(notificationId: notification.notificationId).count == 0 {
                    _ = Constants.databaseManager.notificationsManager.addNotificationToDatabase(newNotification: notification)
                } else {
                    _ = Constants.databaseManager.notificationsManager.markNotificationAsRead(notification: notification)
                }
                self.contadorNotificaciones = self.contadorNotificaciones + 1
            }
         }
        
        operation.queryCompletionBlock = {(cursor : CKQueryOperation.Cursor?, error : Error?) -> Void in
            print("EL NUMERO DE NOTIFICACIONES DESCARGADOS: " + String(self.contadorNotificaciones))
            if cursor != nil {
                let queryCursorOperation = CKQueryOperation(cursor: cursor!)
                self.executeGetNotificacionesOperation(operation: queryCursorOperation, delegate: delegate)
            } else {
                self.checkNotificationsToRemove(cloudNotifications: self.notificationIds)
                if error != nil {
                    print("ERROR DESCARGANDO NOTIFICACIONES")
                    self.notificationIds = []
                    delegate?.notificacionSincronizationError(error: error!.localizedDescription)
                } else {
                    print("EXITO DESCARGANDO NOTIFICACIONES")
                    self.notificationIds = []
                    delegate?.notificacionSincronizationFinished()
                }
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
    
    func saveNotification(notification: NotificationModel, delegate: CloudNotificacionPersonalizadaProtocol?) {
        let notificationRecord: CKRecord = CKRecord(recordType: tableName)
        cloudDatabaseHelper.setNotificationCKRecordVariables(notification: notification, record: notificationRecord)
        
        publicDatabase.save(notificationRecord) { (savedRecord, error) in
            if error != nil {
                print("ERROR GUARDANDO NOTIFICACION")
            } else {
                print("EXITO GUARDANDO NOTIFICACION")
            }
        }
    }
    
    func updateNotification(notification: NotificationModel, delegate: CloudNotificationProtocol) {
        let predicate = NSPredicate(format: "CD_notificationId = %d", notification.notificationId)
        let query = CKQuery(recordType: tableName, predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil  || results!.count == 0 {
                print("ERROR ACTUALIZANDO NOTIFICACION")
                delegate.notificacionSincronizationError(error: error != nil ? error!.localizedDescription : "Error actualizando notificación")
                return
            }
            
            self.cloudDatabaseHelper.setNotificationCKRecordVariables(notification: notification, record: results!.first!)
            
            self.publicDatabase.save(results!.first!, completionHandler: { (newRecord, error) in
                if error != nil {
                    print("ERROR ACTUALIZANDO NOTIFICACION")
                    delegate.notificacionSincronizationError(error: error!.localizedDescription)
                } else {
                    print("EXITO ACTUALIZANDO NOTIFICACION")
                    delegate.notificacionSincronizationFinished()
                }
            })
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
    
    func saveNotifications(notifications: [NotificationModel], delegate: CloudNotificationProtocol?) {
        var arrayRecords: [CKRecord] = []
        for notification in notifications {
            let notificationRecord: CKRecord = CKRecord(recordType: tableName)
            cloudDatabaseHelper.setNotificationCKRecordVariables(notification: notification, record: notificationRecord)
            arrayRecords.append(notificationRecord)
        }
        
        let operation: CKModifyRecordsOperation = CKModifyRecordsOperation()
        operation.recordsToSave = arrayRecords
        operation.savePolicy = .ifServerRecordUnchanged
        
        operation.modifyRecordsCompletionBlock = {savedRecords, deletedRecordIDs, error in
            if error != nil {
                print("ERROR ACTUALIZANDO NOTIFICACIONES")
                delegate?.notificacionSincronizationError(error: error!.localizedDescription)
            } else {
                print("EXITO ACTUALIZANDO NOTIFICACIONES")
                delegate?.notificacionSincronizationFinished()
            }
        }
        
        publicDatabase.add(operation)
    }
    
    func deleteNotifications(notifications: [NotificationModel], notificationType: String, clientId: Int64, delegate: CloudEliminarNotificationsProtocol) {
        var recordIds: [CKRecord.ID] = []
        
        let predicate = NSPredicate(format: "CD_type = %@", notificationType)
        let query = CKQuery(recordType: tableName, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record: CKRecord!) in
            if record != nil {
                let notification: NotificationModel = self.cloudDatabaseHelper.parseCloudNotificationsObjectToLocalNotificationObject(record: record)
                if notification.clientId.count == 1 && notification.clientId.contains(clientId) {
                    recordIds.append(record.recordID)
                }
            }
        }
        operation.queryCompletionBlock = {(cursor : CKQueryOperation.Cursor?, error : Error?) -> Void in
            if error != nil {
                print("ERROR ELIMINANDO NOTIFICACIONES")
                delegate.errorDeletingNotifications(error: error!.localizedDescription)
            } else {
                let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIds)
                deleteOperation.savePolicy = .allKeys
                deleteOperation.modifyRecordsCompletionBlock = { added, deleted, error in
                    if error != nil {
                        print("ERROR ELIMINANDO NOTIFICACIONES")
                        delegate.errorDeletingNotifications(error: error!.localizedDescription)
                    } else {
                        print("EXITO ELIMINANDO NOTIFICACIONES")
                        delegate.succesDeletingNotification(notifications: notifications)
                    }
                }
                
                self.publicDatabase.add(deleteOperation)
            }
         }
        
        publicDatabase.add(operation)
    }
}
