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
    var contadorServicios: Int = 0
    var allCloudServices: [Int64] = []
    
    func getServicios() {
        let query: CKQuery = CKQuery(recordType: tableName, predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        
        executeGetServiciosOperation(operation: operation)
    }
    
    private func executeGetServiciosOperation(operation: CKQueryOperation) {
        operation.recordFetchedBlock = { (record: CKRecord!) in
             if record != nil {
                let servicio: ServiceModel = self.cloudDatabaseHelper.parseCloudServicioObjectToLocalServicioObject(record: record)
                self.allCloudServices.append(servicio.serviceId)
                if Constants.databaseManager.servicesManager.getServiceFromDatabase(serviceId: servicio.serviceId).count == 0 {
                    _ = Constants.databaseManager.servicesManager.addServiceInDatabase(newService: servicio)
                } else {
                    _ = Constants.databaseManager.servicesManager.updateServiceInDatabase(service: servicio)
                }
                self.contadorServicios = self.contadorServicios + 1
            }
        }
        
        operation.queryCompletionBlock = {(cursor : CKQueryOperation.Cursor?, error : Error?) -> Void in
            print("EL NUMERO DE SERVICIOS DESCARGADOS: " + String(self.contadorServicios))
            if cursor != nil {
                let queryCursorOperation = CKQueryOperation(cursor: cursor!)
                self.executeGetServiciosOperation(operation: queryCursorOperation)
            } else {
                if error == nil {
                    print("EXITO DESCARGANDO SERVICIOS")
                    self.deleteLocalServicesIfNeeded(cloudServices: self.allCloudServices)
                    self.contadorServicios = 0
                    self.allCloudServices = []
                } else {
                    print("ERROR DESCARGANDO SERVICIOS")
                    self.contadorServicios = 0
                    self.allCloudServices = []
                }
            }
         }
        
        publicDatabase.add(operation)
    }
    
    func getServiciosPorCliente(clientId: Int64, delegate: CloudServiceManagerProtocol) {
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
            if error != nil {
                delegate.serviceSincronizationError(error: error!.localizedDescription)
            } else {
                self.deleteLocalServicesIfNeededForClient(cloudServices: cloudServices, clientId: clientId)
                delegate.serviceSincronizationFinished()
            }
         }
        
        publicDatabase.add(operation)
    }
    
    func getServiciosPorDia(date: Date, delegate: CloudServiceManagerProtocol) {
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
            if error != nil {
                print("ERROR CARGANDO SERVICIOS DEL DIA")
                delegate.serviceSincronizationError(error: error!.localizedDescription)
            } else {
                print("EXITO CARGANDO SERVICIOS DEL DIA")
                self.checkLocalServicesForDay(cloudServices: cloudServices, date: date)
                delegate.serviceSincronizationFinished()
            }
        }
        
        publicDatabase.add(operation)
    }
    
    func saveService(service: ServiceModel, delegate: CloudServiceManagerProtocol) {
        let serviceRecord: CKRecord = CKRecord(recordType: tableName)
        cloudDatabaseHelper.setServiceCKRecordVariables(service: service, record: serviceRecord)
        
        publicDatabase.save(serviceRecord) { (savedRecord, error) in
            if error != nil {
                delegate.serviceSincronizationError(error: error!.localizedDescription)
            } else {
                delegate.serviceSincronizationFinished()
            }
        }
    }
    
    func saveServices(services: [ServiceModel], delegate: CloudServiceManagerProtocol) {
        var arrayRecords: [CKRecord] = []
        for service in services {
            let serviceRecord: CKRecord = CKRecord(recordType: tableName)
            cloudDatabaseHelper.setServiceCKRecordVariables(service: service, record: serviceRecord)
            arrayRecords.append(serviceRecord)
        }
        
        let operation: CKModifyRecordsOperation = CKModifyRecordsOperation()
        operation.recordsToSave = arrayRecords
        operation.savePolicy = .ifServerRecordUnchanged
        
        operation.modifyRecordsCompletionBlock = {savedRecords, deletedRecordIDs, error in
            if error != nil {
                delegate.serviceSincronizationError(error: error!.localizedDescription)
            } else {
                delegate.serviceSincronizationFinished()
            }
        }
        
        publicDatabase.add(operation)
    }
    
    func deleteService(service: ServiceModel,delegate: CloudEliminarServiceProtocol) {
        let predicate = NSPredicate(format: "CD_serviceId = %d", service.serviceId)
        let query = CKQuery(recordType: tableName, predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil {
                print("ERROR ELIMINANDO SERVICIO")
                delegate.errorEliminandoService(error: error != nil ? error!.localizedDescription : "Error eliminando el servicio")
                return
            }
            
            if results!.count == 0 {
                print("EXITO ELIMINANDO SERVICIO")
                delegate.serviceEliminado(service: service)
                return
            }
            
            self.publicDatabase.delete(withRecordID: results!.first!.recordID) {result, error in
                if error != nil {
                    print("ERROR ELIMINANDO SERVICIO")
                    delegate.errorEliminandoService(error: error!.localizedDescription)
                } else {
                    print("EXITO ELIMINANDO SERVICIO")
                    delegate.serviceEliminado(service: service)
                }
            }
        }
    }
    
    func updateService(service: ServiceModel, delegate: CloudServiceManagerProtocol) {
        let predicate = NSPredicate(format: "CD_serviceId = %d", service.serviceId)
        let query = CKQuery(recordType: tableName, predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil || results!.count == 0 {
                delegate.serviceSincronizationError(error: error != nil ? error!.localizedDescription : "Error actualizando el servicio")
                return
            }
            let record: CKRecord = results!.first!
            self.cloudDatabaseHelper.setServiceCKRecordVariables(service: service, record: record)
            
            self.publicDatabase.save(record, completionHandler: { (newRecord, error) in
                if error != nil {
                    delegate.serviceSincronizationError(error: error!.localizedDescription)
                } else {
                    delegate.serviceSincronizationFinished()
                }
            })
        }
    }
    
    func updateServices(services: [ServiceModel], delegate: CloudServiceManagerProtocol) {
        var serviceIds: [Int64] = []
        for service: ServiceModel in services {
            serviceIds.append(service.serviceId)
        }
        
        let predicate = NSPredicate(format: "CD_serviceId IN %@", serviceIds)
        let query = CKQuery(recordType: tableName, predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) {results, error in
            if error != nil || results!.count == 0 {
                delegate.serviceSincronizationError(error: error != nil ? error!.localizedDescription : "Error actualizando el servicio")
                return
            }
            var recordsToUpdate: [CKRecord] = []
            for record: CKRecord in results! {
                let service: ServiceModel? = self.getServiceForServiceId(services: services, serviceId: record.value(forKey: "CD_serviceId") as! Int64)
                if service != nil {
                    self.cloudDatabaseHelper.setServiceCKRecordVariables(service: service!, record: record)
                    recordsToUpdate.append(record)
                }
            }
            
            let operation: CKModifyRecordsOperation = CKModifyRecordsOperation()
            operation.recordsToSave = recordsToUpdate
            operation.savePolicy = .ifServerRecordUnchanged
            
            operation.modifyRecordsCompletionBlock = {savedRecords, deletedRecordIDs, error in
                if error != nil {
                    delegate.serviceSincronizationError(error: error!.localizedDescription)
                } else {
                    delegate.serviceSincronizationFinished()
                }
            }
            
            self.publicDatabase.add(operation)
        }
    }
    
    private func getServiceForServiceId(services: [ServiceModel], serviceId: Int64) -> ServiceModel? {
        for service: ServiceModel in services {
            if service.serviceId == serviceId {
                return service
            }
        }
        
        return nil
    }
    
    private func deleteLocalServicesIfNeededForClient(cloudServices: [Int64], clientId: Int64) {
        let localServices: [ServiceModel] = Constants.databaseManager.servicesManager.getServicesForClientId(clientId: clientId)
        for localService: ServiceModel in localServices {
            if !cloudServices.contains(localService.serviceId) {
                _ = Constants.databaseManager.servicesManager.deleteService(service: localService)
            }
        }
    }
    
    private func deleteLocalServicesIfNeeded(cloudServices: [Int64]) {
        let localServices: [ServiceModel] = Constants.databaseManager.servicesManager.getAllServicesFromDatabase()
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
        
        if (cloudServices.count == 0) {
            for localService: ServiceModel in localServices {
                _ = Constants.databaseManager.servicesManager.deleteService(service: localService)
            }
        }
    }
}
