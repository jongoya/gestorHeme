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
    let tableName: String = "CD_Servicio"
    
    let publicDatabase: CKDatabase = CKContainer.default().publicCloudDatabase
    let cloudDatabaseHelper: CloudDatabaseHelper = CloudDatabaseHelper()
    
    func getServicios(delegate: CloudServiceManagerProtocol?) {
        let query: CKQuery = CKQuery(recordType: tableName, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "CD_fecha", ascending: false)]
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record: CKRecord!) in
             if record != nil {
                let servicio: ServiceModel = self.cloudDatabaseHelper.parseCloudServicioObjectToLocalServicioObject(record: record)
                
                if Constants.databaseManager.servicesManager.getServiceFromDatabase(serviceId: servicio.serviceId).count == 0 {
                    _ = Constants.databaseManager.servicesManager.addServiceInDatabase(newService: servicio)
                } else {
                    _ = Constants.databaseManager.servicesManager.updateServiceInDatabase(service: servicio)
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
    
    func getServiciosPorCliente(clientId: Int64, delegate: CloudServiceManagerProtocol?) {
        var cloudServices: [Int64] = []
        let predicate = NSPredicate(format: "CD_clientId = %d", clientId)
        let query: CKQuery = CKQuery(recordType: tableName, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "CD_fecha", ascending: false)]
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record: CKRecord!) in
            if record != nil {
                let servicio: ServiceModel = self.cloudDatabaseHelper.parseCloudServicioObjectToLocalServicioObject(record: record)
                cloudServices.append(servicio.serviceId)
                if Constants.databaseManager.servicesManager.getServiceFromDatabase(serviceId: servicio.serviceId).count == 0 {
                    _ = Constants.databaseManager.servicesManager.addServiceInDatabase(newService: servicio)
                } else {
                    _ = Constants.databaseManager.servicesManager.updateServiceInDatabase(service: servicio)
                }
             }
         }
        
        operation.queryCompletionBlock = {(cursor : CKQueryOperation.Cursor?, error : Error?) -> Void in
            DispatchQueue.main.async {
                self.checkLocalServicesForClient(cloudServices: cloudServices, clientId: clientId)
                delegate?.sincronisationFinished()
            }
         }
        
        publicDatabase.add(operation)
    }
    
    func getServiciosPorDia(date: Date, delegate: CloudServiceManagerProtocol?) {
        let beginingOfDay: Int64 = Int64(AgendaFunctions.getBeginningOfDayFromDate(date: date).timeIntervalSince1970)
        let endOfDay: Int64 = Int64(AgendaFunctions.getEndOfDayFromDate(date: date).timeIntervalSince1970)
        var cloudServices: [Int64] = []
        
        let predicate = NSPredicate(format: "CD_fecha > %d AND CD_fecha < %d", beginingOfDay, endOfDay)
        let query: CKQuery = CKQuery(recordType: tableName, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "CD_fecha", ascending: false)]
        
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { (record: CKRecord!) in
            if record != nil {
                let servicio: ServiceModel = self.cloudDatabaseHelper.parseCloudServicioObjectToLocalServicioObject(record: record)
                cloudServices.append(servicio.serviceId)
                if Constants.databaseManager.servicesManager.getServiceFromDatabase(serviceId: servicio.serviceId).count == 0 {
                    _ = Constants.databaseManager.servicesManager.addServiceInDatabase(newService: servicio)
                } else {
                    _ = Constants.databaseManager.servicesManager.updateServiceInDatabase(service: servicio)
                }
             }
         }
        
        operation.queryCompletionBlock = {(cursor : CKQueryOperation.Cursor?, error : Error?) -> Void in
            DispatchQueue.main.async {
                self.checkLocalServicesForDay(cloudServices: cloudServices, date: date)
                delegate?.sincronisationFinished()
            }
         }
        
        publicDatabase.add(operation)
    }
    
    func saveService(service: ServiceModel) {
        CommonFunctions.showLoadingStateView(descriptionText: "Guardando servicio")
        let serviceRecord: CKRecord = CKRecord(recordType: tableName)
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
        let query = CKQuery(recordType: tableName, predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil  || results!.count == 0 {
                CommonFunctions.hideLoadingStateView()
                CommonFunctions.showGenericAlertMessage(mensaje: "Error eliminando el servicio, inténtelo de nuevo", viewController: CommonFunctions.getRootViewController())
                return
            }
            
            self.publicDatabase.delete(withRecordID: results!.first!.recordID) {result, error in
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
        let query = CKQuery(recordType: tableName, predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil  || results!.count == 0 {
                CommonFunctions.hideLoadingStateView()
                if showLoadingState {
                    CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando el servicio, intentelo de nuevo", viewController: CommonFunctions.getRootViewController())
                }
                
                return
            }
            
            self.cloudDatabaseHelper.setServiceCKRecordVariables(service: service, record: results!.first!)
            
            self.publicDatabase.save(results!.first!, completionHandler: { (newRecord, error) in
                CommonFunctions.hideLoadingStateView()
                if error != nil && showLoadingState {
                    CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando el servicio, intentelo de nuevo", viewController: CommonFunctions.getRootViewController())
                }
                
            })
        }
    }
    
    private func checkLocalServicesForClient(cloudServices: [Int64], clientId: Int64) {
        let localServices: [ServiceModel] = Constants.databaseManager.servicesManager.getServicesForClientId(clientId: clientId)
        for localService: ServiceModel in localServices {
            if !cloudServices.contains(localService.serviceId) {
                _ = Constants.databaseManager.servicesManager.deleteService(service: localService)
            }
        }
    }
    
    private func checkLocalServicesForDay(cloudServices: [Int64], date: Date) {
        let localServices: [ServiceModel] = Constants.databaseManager.servicesManager.getServicesForDay(date: date)
        for localService: ServiceModel in localServices {
            if !cloudServices.contains(localService.serviceId) {
                _ = Constants.databaseManager.servicesManager.deleteService(service: localService)
            }
        }
    }
}
