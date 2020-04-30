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
    var contadorClientes: Int = 0
    
    func getClients(delegate: CloudClientManagerProtocol) {
        let operation = CKQueryOperation(query: CKQuery(recordType: tableName, predicate: NSPredicate(value: true)))
        executeGetClientsOperation(operation: operation, delegate: delegate)
    }
    
    private func executeGetClientsOperation(operation: CKQueryOperation, delegate: CloudClientManagerProtocol) {
        operation.recordFetchedBlock = { (record: CKRecord!) in
            if record != nil {
                let client: ClientModel = self.cloudDatabaseHelper.parseCloudCLientObjectToLocalCLientObject(record: record)
                if Constants.databaseManager.clientsManager.getCoreClientFromDatabase(clientId: client.id).count == 0 {
                    _ = Constants.databaseManager.clientsManager.addClientToDatabase(newClient: client)
                } else {
                    _ = Constants.databaseManager.clientsManager.updateClientInDatabase(client: client)
                    _ = Constants.databaseManager.servicesManager.updateServicesForClientId(clientId: client.id)
                }
                self.contadorClientes = self.contadorClientes + 1
            }
         }
        operation.queryCompletionBlock = {(cursor : CKQueryOperation.Cursor?, error : Error?) -> Void in
            print("EL NUMERO DE CLIENTES DESCARGADOS: " + String(self.contadorClientes))
            if cursor != nil {
                let queryCursorOperation = CKQueryOperation(cursor: cursor!)
                self.executeGetClientsOperation(operation: queryCursorOperation, delegate: delegate)
            } else {
                if error == nil {
                    self.contadorClientes = 0
                    delegate.clientSincronizationFinished()
                } else {
                    self.contadorClientes = 0
                    delegate.clientSincronizationError(error: error!.localizedDescription)
                }
            }
         }
        
        publicDatabase.add(operation)
    }
    
    func saveClient(client: ClientModel, delegate: CloudClientManagerProtocol) {
        let clientRecord: CKRecord = CKRecord(recordType: tableName)
        cloudDatabaseHelper.setClientCKRecordVariables(client: client, record: clientRecord)
        
        publicDatabase.save(clientRecord) { (savedRecord, error) in
            DispatchQueue.main.async {
                if error != nil {
                    delegate.clientSincronizationError(error: error!.localizedDescription)
                } else {
                    delegate.clientSincronizationFinished()
                }
            }
        }
    }
    
    func updateClient(client: ClientModel, delegate: CloudClientManagerProtocol?, notificationDelegate: CloudNotificacionPersonalizadaProtocol?) {
        let predicate = NSPredicate(format: "CD_idCliente = %d", client.id)
        let query = CKQuery(recordType: tableName, predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil  || results!.count == 0 {
                print("ERROR ACTUALIZANDO CLIENTE")
                delegate?.clientSincronizationError(error: error != nil ? error!.localizedDescription :  "Error actualizando cliente")
                notificationDelegate?.errorUpdatingClient(error: error != nil ? error!.localizedDescription : "Error actualizando cliente")
                return
            }
            
            self.cloudDatabaseHelper.setClientCKRecordVariables(client: client, record: results!.first!)
            
            self.publicDatabase.save(results!.first!, completionHandler: { (newRecord, error) in
                if error != nil {
                    print("ERROR ACTUALIZANDO CLIENTE")
                    delegate?.clientSincronizationError(error: error!.localizedDescription)
                    notificationDelegate?.errorUpdatingClient(error: error!.localizedDescription)
                } else {
                    print("EXITO ACTUALIZANDO CLIENTE")
                    delegate?.clientSincronizationFinished()
                    notificationDelegate?.clientUpdated()
                }
            })
        }
    }
}
