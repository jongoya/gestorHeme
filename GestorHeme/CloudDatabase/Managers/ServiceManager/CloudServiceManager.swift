//
//  CloudServiceManager.swift
//  GestorHeme
//
//  Created by jon mikel on 17/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import CloudKit

class CloudServiceManager {
    let servicesQuery: CKQuery = CKQuery(recordType: "CD_Servicio", predicate: NSPredicate(value: true))
    let serviceRecord: CKRecord = CKRecord(recordType: "CD_Servicio")
    let publicDatabase: CKDatabase = CKContainer.default().publicCloudDatabase
    let cloudDatabaseHelper: CloudDatabaseHelper = CloudDatabaseHelper()
    
    func getServicios() {
        let operation = CKQueryOperation(query: servicesQuery)
        operation.recordFetchedBlock = { (record: CKRecord!) in
             if record != nil{
                let servicio: ServiceModel = self.cloudDatabaseHelper.parseCloudServicioObjectToLocalServicioObject(record: record)
                
                if Constants.databaseManager.servicesManager.getServiceFromDatabase(serviceId: servicio.serviceId).count == 0 {
                    _ = Constants.databaseManager.servicesManager.addServiceInDatabase(newService: servicio)
                } else {
                    _ = Constants.databaseManager.servicesManager.updateServiceInDatabase(service: servicio)
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
    
    func saveService(service: ServiceModel) {
        CommonFunctions.showLoadingStateView(descriptionText: "Guardando servicio")
        cloudDatabaseHelper.setServiceCKRecordVariables(service: service, record: serviceRecord)
        
        publicDatabase.save(serviceRecord) { (savedRecord, error) in
            CommonFunctions.hideLoadingStateView()
            if error != nil {
                CommonFunctions.showGenericAlertMessage(mensaje: "Error guardando el servicio, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
            }
        }
    }
    
    func deleteService(service: ServiceModel) {
        CommonFunctions.showLoadingStateView(descriptionText: "Eliminando servicio")
        let predicate = NSPredicate(format: "CD_serviceId = %d", service.serviceId)
        let query = CKQuery(recordType: "CD_Servicio", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil  || results!.count == 0 {
                CommonFunctions.hideLoadingStateView()
                CommonFunctions.showGenericAlertMessage(mensaje: "Error eliminando el servicio, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
                return
            }
            
            let recordToDelete: CKRecord! = results!.first!
            self.publicDatabase.delete(withRecordID: recordToDelete.recordID) {result, error in
                CommonFunctions.hideLoadingStateView()
               if error != nil {
                   CommonFunctions.showGenericAlertMessage(mensaje: "Error eliminando el servicio, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
               }
            }
        }
    }
    
    func updateService(service: ServiceModel, showLoadingState: Bool) {
        if showLoadingState {
            CommonFunctions.showLoadingStateView(descriptionText: "Actualizando servicio")
        }
        let predicate = NSPredicate(format: "CD_serviceId = %d", service.serviceId)
        let query = CKQuery(recordType: "CD_Servicio", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil  || results!.count == 0 {
                CommonFunctions.hideLoadingStateView()
                if showLoadingState {
                    CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando el servicio, intentelo de nuevo", viewController: CommonFunctions.getRootViewController())
                }
                
                return
            }
            
            let recordToUpdate: CKRecord! = results!.first!
            self.cloudDatabaseHelper.setServiceCKRecordVariables(service: service, record: recordToUpdate)
            
            self.publicDatabase.save(recordToUpdate, completionHandler: { (newRecord, error) in
                CommonFunctions.hideLoadingStateView()
                if error != nil && showLoadingState {
                    CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando el servicio, intentelo de nuevo", viewController: CommonFunctions.getRootViewController())
                }
                
            })
        }
    }
}
