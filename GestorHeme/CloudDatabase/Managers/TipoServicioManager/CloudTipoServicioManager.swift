//
//  CloudTipoServicioManager.swift
//  GestorHeme
//
//  Created by jon mikel on 17/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import CloudKit

class CloudTipoServicioManager {
    let tipoServiciosQuery: CKQuery = CKQuery(recordType: "CD_TipoServicios", predicate: NSPredicate(value: true))
    let tipoServicioRecord: CKRecord = CKRecord(recordType: "CD_TipoServicios")
    let publicDatabase: CKDatabase = CKContainer.default().publicCloudDatabase
    let cloudDatabaseHelper: CloudDatabaseHelper = CloudDatabaseHelper()
    
    func getTipoServicios() {
        let operation = CKQueryOperation(query: tipoServiciosQuery)
        operation.recordFetchedBlock = { (record: CKRecord!) in
             if record != nil{
                let tipoServicio: TipoServicioModel = self.cloudDatabaseHelper.parseCloudTipoServicioObjectToLocalTipoServicioObject(record: record)
                _ = Constants.databaseManager.tipoServiciosManager.addTipoServicioToDatabase(servicio: tipoServicio)
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
    
    func saveTipoServicio(tipoServicio: TipoServicioModel) {
        CommonFunctions.showLoadingStateView(descriptionText: "Guardando servicio")
        cloudDatabaseHelper.setTipoServicioCKRecordVariables(tipoServicio: tipoServicio, record: tipoServicioRecord)
        
        publicDatabase.save(tipoServicioRecord) { (savedRecord, error) in
            CommonFunctions.hideLoadingStateView()
            if error != nil {
                CommonFunctions.showGenericAlertMessage(mensaje: "Erro guardando servicio, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
            }
        }
    }
}
