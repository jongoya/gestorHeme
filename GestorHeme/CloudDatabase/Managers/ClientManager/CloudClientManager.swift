//
//  CloudCLientManager.swift
//  GestorHeme
//
//  Created by jon mikel on 17/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import CloudKit

class CloudClientManager {
    let clientQuery: CKQuery = CKQuery(recordType: "CD_Cliente", predicate: NSPredicate(value: true))
    let clientRecord: CKRecord = CKRecord(recordType: "CD_Cliente")
    
    let publicDatabase: CKDatabase = CKContainer.default().publicCloudDatabase
    let cloudDatabaseHelper: CloudDatabaseHelper = CloudDatabaseHelper()
    
    func getClients() {
        let operation = CKQueryOperation(query: clientQuery)
        operation.recordFetchedBlock = { (record: CKRecord!) in
             if record != nil{
                let client: ClientModel = self.cloudDatabaseHelper.parseCloudCLientObjectToLocalCLientObject(record: record)
                if Constants.databaseManager.clientsManager.getCoreClientFromDatabase(clientId: client.id).count == 0 {
                    _ = Constants.databaseManager.clientsManager.addClientToDatabase(newClient: client)
                } else {
                    _ = Constants.databaseManager.clientsManager.updateClientInDatabase(client: client)
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
    
    func saveClient(client: ClientModel) {
        CommonFunctions.showLoadingStateView(descriptionText: "Guardando cliente")
        cloudDatabaseHelper.setClientCKRecordVariables(client: client, record: clientRecord)
        
        publicDatabase.save(clientRecord) { (savedRecord, error) in
            CommonFunctions.hideLoadingStateView()
            if error != nil {
                CommonFunctions.showGenericAlertMessage(mensaje: "Error guardando cliente, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
            }
        }
    }
    
    func updateClient(client: ClientModel) {
        CommonFunctions.showLoadingStateView(descriptionText: "Actualizando cliente")
        let predicate = NSPredicate(format: "CD_idCliente = %d", client.id)
        let query = CKQuery(recordType: "CD_Cliente", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil  || results!.count == 0 {
                CommonFunctions.hideLoadingStateView()
                CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando cliente, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
                return
            }
            
            let recordToUpdate: CKRecord! = results!.first!
            self.cloudDatabaseHelper.setClientCKRecordVariables(client: client, record: recordToUpdate)
            
            self.publicDatabase.save(recordToUpdate, completionHandler: { (newRecord, error) in
                CommonFunctions.hideLoadingStateView()
                if error != nil {
                    CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando cliente, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
                }
                
            })
        }
    }
}
