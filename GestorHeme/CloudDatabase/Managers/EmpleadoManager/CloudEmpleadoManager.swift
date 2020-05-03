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
    let tableName: String = "CD_Empleado"
    
    let publicDatabase: CKDatabase = CKContainer.default().publicCloudDatabase
    let cloudDatabaseHelper: CloudDatabaseHelper = CloudDatabaseHelper()
    
    func getEmpleados(delegate: CloudEmpleadoProtocol?) {
        var empleadoIds: [Int64] = []
        let operation = CKQueryOperation(query: CKQuery(recordType: tableName, predicate: NSPredicate(value: true)))
        
        operation.recordFetchedBlock = { (record: CKRecord!) in
             if record != nil {
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
            DispatchQueue.main.async {
                if error != nil {
                    delegate?.empleadoSincronizationError(error: error!.localizedDescription)
                } else {
                    self.checkEmpleadosToRemove(cloudEmpleados: empleadoIds)
                    delegate?.empleadoSincronizationFinished()
                }
            }
         }

        publicDatabase.add(operation)
    }
    
    private func checkEmpleadosToRemove(cloudEmpleados: [Int64]) {
        let localEmpleados: [EmpleadoModel] = Constants.databaseManager.empleadosManager.getAllEmpleadosFromDatabase()
        for empleadoLocal: EmpleadoModel in localEmpleados {
            if !cloudEmpleados.contains(empleadoLocal.empleadoId) {
                _ = Constants.databaseManager.empleadosManager.eliminarEmpleado(empleadoId: empleadoLocal.empleadoId)
            }
        }
    }
    
    func saveEmpleado(empleado: EmpleadoModel, delegate: CloudEmpleadoProtocol) {
        let empleadoRecord: CKRecord = CKRecord(recordType: tableName)
        cloudDatabaseHelper.setEmpleadoCKRecordVariables(empleado: empleado, record: empleadoRecord)
        
        publicDatabase.save(empleadoRecord) { (savedRecord, error) in
            DispatchQueue.main.async {
                if error != nil {
                    delegate.empleadoSincronizationError(error: error!.localizedDescription)
                } else {
                    delegate.empleadoSincronizationFinished()
                }
            }
        }
    }
    
    func deleteEmpleado(empleado: EmpleadoModel, delegate: CloudEmpleadoProtocol) {
        let predicate = NSPredicate(format: "CD_empleadoId = %d", empleado.empleadoId)
        let query = CKQuery(recordType: tableName, predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil {
                delegate.empleadoSincronizationError(error: error != nil ? error!.localizedDescription : "Error eliminando el empleado")
                return
            }
            
            if results!.count == 0 {
                delegate.empleadoDeleted(empleado: empleado)
                return
            }
            
            self.publicDatabase.delete(withRecordID: results!.first!.recordID) {result, error in
                DispatchQueue.main.async {
                    if error != nil {
                        delegate.empleadoSincronizationError(error: error!.localizedDescription)
                    } else {
                        delegate.empleadoDeleted(empleado: empleado)
                    }
                }
            }
        }
    }
    
    func updateEmpleado(empleado: EmpleadoModel, delegate: CloudEmpleadoProtocol) {
        let predicate = NSPredicate(format: "CD_empleadoId = %d", empleado.empleadoId)
        let query = CKQuery(recordType: tableName, predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil  || results!.count == 0 {
                delegate.empleadoSincronizationError(error: error != nil ? error!.localizedDescription : "Error actualizando empleado")
                return
            }
            
            self.cloudDatabaseHelper.setEmpleadoCKRecordVariables(empleado: empleado, record: results!.first!)
            
            self.publicDatabase.save(results!.first!, completionHandler: { (newRecord, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        delegate.empleadoSincronizationError(error: error!.localizedDescription)
                    } else {
                        delegate.empleadoSincronizationFinished()
                    }
                }
            })
        }
    }
}
