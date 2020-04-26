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
    let tableName: String = "CD_Cliente"
    
    let publicDatabase: CKDatabase = CKContainer.default().publicCloudDatabase
    let cloudDatabaseHelper: CloudDatabaseHelper = CloudDatabaseHelper()
    
    func getClients(delegate: CloudClientManagerProtocol?) {
        let operation = CKQueryOperation(query: CKQuery(recordType: tableName, predicate: NSPredicate(value: true)))
        operation.recordFetchedBlock = { (record: CKRecord!) in
            if record != nil {
                let client: ClientModel = self.cloudDatabaseHelper.parseCloudCLientObjectToLocalCLientObject(record: record)
                if Constants.databaseManager.clientsManager.getCoreClientFromDatabase(clientId: client.id).count == 0 {
                    _ = Constants.databaseManager.clientsManager.addClientToDatabase(newClient: client)
                } else {
                    _ = Constants.databaseManager.clientsManager.updateClientInDatabase(client: client)
                }
             }
         }
        operation.queryCompletionBlock = {(cursor : CKQueryOperation.Cursor?, error : Error?) -> Void in
            DispatchQueue.main.async {
                delegate?.sincronisationFinished()
            }
         }

        publicDatabase.add(operation)
    }
    
    func saveClient(client: ClientModel) {
        CommonFunctions.showLoadingStateView(descriptionText: "Guardando cliente")
        
        let clientRecord: CKRecord = CKRecord(recordType: tableName)
        cloudDatabaseHelper.setClientCKRecordVariables(client: client, record: clientRecord)
        
        publicDatabase.save(clientRecord) { (savedRecord, error) in
            CommonFunctions.hideLoadingStateView()
            if error != nil {
                CommonFunctions.showGenericAlertMessage(mensaje: "Error guardando cliente, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
            }
        }
    }
    
    func updateClient(client: ClientModel, showLoadingState: Bool) {
        if showLoadingState {
            CommonFunctions.showLoadingStateView(descriptionText: "Actualizando cliente")
        }
        
        let predicate = NSPredicate(format: "CD_idCliente = %d", client.id)
        let query = CKQuery(recordType: tableName, predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil  || results!.count == 0 {
                CommonFunctions.hideLoadingStateView()
                CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando cliente, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
                return
            }
            
            self.cloudDatabaseHelper.setClientCKRecordVariables(client: client, record: results!.first!)
            
            self.publicDatabase.save(results!.first!, completionHandler: { (newRecord, error) in
                CommonFunctions.hideLoadingStateView()
                if error != nil {
                    CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando cliente, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
                }
                
            })
        }
    }
}
