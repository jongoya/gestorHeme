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
    let cierreCajaQuery: CKQuery = CKQuery(recordType: "CD_CierreCaja", predicate: NSPredicate(value: true))
    let publicDatabase: CKDatabase = CKContainer.default().publicCloudDatabase
    let cloudDatabaseHelper: CloudDatabaseHelper = CloudDatabaseHelper()
    
    func getCierreCajas() {
        let operation = CKQueryOperation(query: cierreCajaQuery)
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
        CommonFunctions.showLoadingStateView(descriptionText: "Guardando servicio")
        let cierreCajaRecord: CKRecord = CKRecord(recordType: "CD_CierreCaja")
        cloudDatabaseHelper.setCierreCajaCKRecordVariables(cierreCaja: cierreCaja, record: cierreCajaRecord)
        
        publicDatabase.save(cierreCajaRecord) { (savedRecord, error) in
            CommonFunctions.hideLoadingStateView()
            if error != nil {
                CommonFunctions.showGenericAlertMessage(mensaje: "Error guardando servicio, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
            }
        }
    }
}
