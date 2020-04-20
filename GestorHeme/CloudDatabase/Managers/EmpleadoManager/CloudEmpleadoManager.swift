//
//  CloudEmpleadoManager.swift
//  GestorHeme
//
//  Created by jon mikel on 17/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import CloudKit

class CloudEmpleadoManager {
    let empleadoQuery: CKQuery = CKQuery(recordType: "CD_Empleado", predicate: NSPredicate(value: true))
    let empleadoRecord: CKRecord = CKRecord(recordType: "CD_Empleado")
    let publicDatabase: CKDatabase = CKContainer.default().publicCloudDatabase
    let cloudDatabaseHelper: CloudDatabaseHelper = CloudDatabaseHelper()
    
    func getEmpleados(delegate: CloudEmpleadoProtocol?) {
        let operation = CKQueryOperation(query: empleadoQuery)
        var empleadoIds: [Int64] = []
        operation.recordFetchedBlock = { (record: CKRecord!) in
             if record != nil{
                let empleado: EmpleadoModel = self.cloudDatabaseHelper.parseCloudEmpleadoObjectToLocalEmpleadoObject(record: record)
                empleadoIds.append(empleado.empleadoId)
                if Constants.databaseManager.empleadosManager.getCoreEmpleadoFromDatabase(empleadoId: empleado.empleadoId).count == 0 {
                    _ = Constants.databaseManager.empleadosManager.addEmpleadoToDatabase(newEmpleado: empleado)
                } else {
                    _ = Constants.databaseManager.empleadosManager.updateEmpleado(empleado: empleado)
                }
             }
         }
        
        operation.queryCompletionBlock = {(cursor : CKQueryOperation.Cursor?, error : Error?) -> Void in
            self.checkEmpleadosToRemove(cloudEmpleados: empleadoIds)
            DispatchQueue.main.async {
                delegate?.sincronisationFinished()
            }
         }

        publicDatabase.add(operation)
    }
    
    private func checkEmpleadosToRemove(cloudEmpleados: [Int64]) {
        let localEmpleados: [EmpleadoModel] = Constants.databaseManager.empleadosManager.getAllEmpleadosFromDatabase()
        for empleadoLocal: EmpleadoModel in localEmpleados {
            let empleadoExiste: Bool = cloudEmpleados.contains(empleadoLocal.empleadoId)
            if !empleadoExiste {
                _ = Constants.databaseManager.empleadosManager.eliminarEmpleado(empleadoId: empleadoLocal.empleadoId)
            }
        }
    }
    
    func saveEmpleado(empleado: EmpleadoModel) {
        CommonFunctions.showLoadingStateView(descriptionText: "Guardando empleado")
        
        cloudDatabaseHelper.setEmpleadoCKRecordVariables(empleado: empleado, record: empleadoRecord)
        
        publicDatabase.save(empleadoRecord) { (savedRecord, error) in
            CommonFunctions.hideLoadingStateView()
            if error != nil {
                CommonFunctions.showGenericAlertMessage(mensaje: "Error guardando empleado, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
            }
        }
    }
    
    func deleteEmpleado(empleado: EmpleadoModel) {
        CommonFunctions.showLoadingStateView(descriptionText: "Eliminando empleado")
        let predicate = NSPredicate(format: "CD_empleadoId = %d", empleado.empleadoId)
        let query = CKQuery(recordType: "CD_Empleado", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil  || results!.count == 0 {
                CommonFunctions.hideLoadingStateView()
                CommonFunctions.showGenericAlertMessage(mensaje: "Error eliminando empleado, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
                return
            }
            
            let recordToDelete: CKRecord! = results!.first!
            self.publicDatabase.delete(withRecordID: recordToDelete.recordID) {result, error in
                CommonFunctions.hideLoadingStateView()
                if error != nil {
                   CommonFunctions.showGenericAlertMessage(mensaje: "Error eliminando empleado, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
                }
            }
        }
    }
    
    func updateEmpleado(empleado: EmpleadoModel) {
        CommonFunctions.showLoadingStateView(descriptionText: "Actualizando empleado")
        let predicate = NSPredicate(format: "CD_empleadoId = %d", empleado.empleadoId)
        let query = CKQuery(recordType: "CD_Empleado", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil  || results!.count == 0 {
                CommonFunctions.hideLoadingStateView()
                CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando usuario, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
                return
            }
            
            let recordToUpdate: CKRecord! = results!.first!
            self.cloudDatabaseHelper.setEmpleadoCKRecordVariables(empleado: empleado, record: recordToUpdate)
            
            self.publicDatabase.save(recordToUpdate, completionHandler: { (newRecord, error) in
                CommonFunctions.hideLoadingStateView()
                if error != nil {
                    CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando usuario, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
                }
            })
        }
    }
}
