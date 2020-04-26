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
    
    func getCierreCajas() {
        let operation = CKQueryOperation(query: CKQuery(recordType: tableName, predicate: NSPredicate(value: true)))
        operation.recordFetchedBlock = { (record: CKRecord!) in
             if record != nil{
                let cierreCaja: CierreCajaModel = self.cloudDatabaseHelper.parseCloudCierreCajaObjectToLocalCierreCajaObject(record: record)
                _ = Constants.databaseManager.cierreCajaManager.addCierreCajaToDatabase(newCierreCaja: cierreCaja)
             }
         }
        
        operation.queryCompletionBlock = {(cursor : CKQueryOperation.Cursor?, error : Error?) -> Void in
            DispatchQueue.main.async {
                //TODO incluir un delegate si es necesario
            }
         }

        publicDatabase.add(operation)
    }
    
    func saveCierreCaja(cierreCaja: CierreCajaModel) {
        CommonFunctions.showLoadingStateView(descriptionText: "Guardando cierre caja")
        let cierreCajaRecord: CKRecord = CKRecord(recordType: tableName)
        cloudDatabaseHelper.setCierreCajaCKRecordVariables(cierreCaja: cierreCaja, record: cierreCajaRecord)
        
        publicDatabase.save(cierreCajaRecord) { (savedRecord, error) in
            CommonFunctions.hideLoadingStateView()
            if error != nil {
                CommonFunctions.showGenericAlertMessage(mensaje: "Error guardando el cierre de caja, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
            }
        }
    }
}
