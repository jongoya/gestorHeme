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
    let tableName: String = "CD_TipoServicios"
    
    let publicDatabase: CKDatabase = CKContainer.default().publicCloudDatabase
    let cloudDatabaseHelper: CloudDatabaseHelper = CloudDatabaseHelper()
    
    func getTipoServicios(delegate: CloudTipoServiciosProtocol?) {
        let operation = CKQueryOperation(query: CKQuery(recordType: tableName, predicate: NSPredicate(value: true)))
        operation.recordFetchedBlock = { (record: CKRecord!) in
             if record != nil{
                let tipoServicio: TipoServicioModel = self.cloudDatabaseHelper.parseCloudTipoServicioObjectToLocalTipoServicioObject(record: record)
                _ = Constants.databaseManager.tipoServiciosManager.addTipoServicioToDatabase(servicio: tipoServicio)
             }
         }
        
        operation.queryCompletionBlock = {(cursor : CKQueryOperation.Cursor?, error : Error?) -> Void in
            DispatchQueue.main.async {
                delegate?.sincronisationFinished()
            }
         }

        publicDatabase.add(operation)
    }
    
    func saveTipoServicio(tipoServicio: TipoServicioModel) {
        CommonFunctions.showLoadingStateView(descriptionText: "Guardando servicio")
        
        let tipoServicioRecord: CKRecord = CKRecord(recordType: tableName)
        cloudDatabaseHelper.setTipoServicioCKRecordVariables(tipoServicio: tipoServicio, record: tipoServicioRecord)
        
        publicDatabase.save(tipoServicioRecord) { (savedRecord, error) in
            CommonFunctions.hideLoadingStateView()
            if error != nil {
                CommonFunctions.showGenericAlertMessage(mensaje: "Erro guardando servicio, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
            }
        }
    }
}
