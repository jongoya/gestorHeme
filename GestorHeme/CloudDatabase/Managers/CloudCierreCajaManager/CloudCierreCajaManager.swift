//
//  CloudCierreCajaManager.swift
//  GestorHeme
//
//  Created by jon mikel on 21/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import CloudKit

class CloudCierreCajaManager {
    let tableName: String = "CD_CierreCaja"
    
    let publicDatabase: CKDatabase = CKContainer.default().publicCloudDatabase
    let cloudDatabaseHelper: CloudDatabaseHelper = CloudDatabaseHelper()
    var contadorCierreCajas: Int = 0
    
    func getCierreCajas() {
        let operation = CKQueryOperation(query: CKQuery(recordType: tableName, predicate: NSPredicate(value: true)))
        executeGetCierreCajasOperation(operation: operation)
    }
    
    private func executeGetCierreCajasOperation(operation: CKQueryOperation) {
        operation.recordFetchedBlock = { (record: CKRecord!) in
             if record != nil{
                let cierreCaja: CierreCajaModel = self.cloudDatabaseHelper.parseCloudCierreCajaObjectToLocalCierreCajaObject(record: record)
                _ = Constants.databaseManager.cierreCajaManager.addCierreCajaToDatabase(newCierreCaja: cierreCaja)
             }
            
            self.contadorCierreCajas = self.contadorCierreCajas + 1
         }
        
        operation.queryCompletionBlock = {(cursor : CKQueryOperation.Cursor?, error : Error?) -> Void in
            print("EL NUMERO DE CIERRECAJAS DESCARGADOS: " + String(self.contadorCierreCajas))
            if cursor != nil {
                let queryCursorOperation = CKQueryOperation(cursor: cursor!)
                self.executeGetCierreCajasOperation(operation: queryCursorOperation)
            } else {
                if error == nil {
                    self.contadorCierreCajas = 0
                    print("EXITO DESCARGANDO CIERRE CAJAS")
                } else {
                    self.contadorCierreCajas = 0
                    print("ERROR DESCARGANDO CIERRE CAJAS")
                }
            }
         }

        publicDatabase.add(operation)
    }
    
    func saveCierreCaja(cierreCaja: CierreCajaModel, delegate: CloudCierreCajaProtocol) {
        let cierreCajaRecord: CKRecord = CKRecord(recordType: tableName)
        cloudDatabaseHelper.setCierreCajaCKRecordVariables(cierreCaja: cierreCaja, record: cierreCajaRecord)
        
        publicDatabase.save(cierreCajaRecord) { (savedRecord, error) in
            if error != nil {
                delegate.errorSavingCierreCaja()
            } else {
                delegate.cierreCajaSaved()
            }
        }
    }
}
