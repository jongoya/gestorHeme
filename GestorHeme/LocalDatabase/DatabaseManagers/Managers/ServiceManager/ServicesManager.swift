//
//  ServvicesManager.swift
//  GestorHeme
//
//  Created by jon mikel on 02/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import  CoreData


class ServicesManager: NSObject {
    let SERVICES_ENTITY_NAME: String = "Servicio"
    var databaseHelper: DatabaseHelper!
    
    var backgroundContext: NSManagedObjectContext!//para escritura
    var mainContext: NSManagedObjectContext!//para lectura
    
    override init() {
        super.init()
        let app = UIApplication.shared.delegate as! AppDelegate
        backgroundContext = app.persistentContainer.newBackgroundContext()
        mainContext = app.persistentContainer.viewContext
        databaseHelper = DatabaseHelper()
    }
    
    func getAllServicesFromDatabase() -> [ServiceModel] {
        var services: [ServiceModel] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: SERVICES_ENTITY_NAME)
        fetchRequest.returnsObjectsAsFaults = false
        
        mainContext.performAndWait {
            do {
                let results: [NSManagedObject] = try mainContext.fetch(fetchRequest)
                for data in results {
                    services.append(databaseHelper.parseServiceCoreObjectToServiceModel(coreObject: data))
                }
            } catch {
            }
        }

        return services
    }
    
    func getAllServicesForDay(beginingOfDay: Int64, endOfDay: Int64) -> [ServiceModel] {
        var services: [ServiceModel] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: SERVICES_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "fecha > %f AND fecha < %f", argumentArray: [beginingOfDay, endOfDay])
        fetchRequest.returnsObjectsAsFaults = false
        
        mainContext.performAndWait {
            do {
                let results: [NSManagedObject] = try mainContext.fetch(fetchRequest)
                for data in results {
                    services.append(databaseHelper.parseServiceCoreObjectToServiceModel(coreObject: data))
                }
            } catch {
            }
        }

        return services
    }
    
    func getServicesForClientId(clientId: Int64) -> [ServiceModel] {
        var services: [ServiceModel] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: SERVICES_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "idCliente = %f", argumentArray: [clientId])
        fetchRequest.returnsObjectsAsFaults = false
        
        mainContext.performAndWait {
            do {
                let results: [NSManagedObject] = try mainContext.fetch(fetchRequest)
                for data in results {
                    services.append(databaseHelper.parseServiceCoreObjectToServiceModel(coreObject: data))
                }
            } catch {
            }
        }

        return services
    }
    
    func addServiceInDatabase(newService: ServiceModel) -> Bool {
        let entity = NSEntityDescription.entity(forEntityName: SERVICES_ENTITY_NAME, in: backgroundContext)
        
        if getServiceFromDatabase(serviceId: newService.serviceId).count == 0 {
            let coreService = NSManagedObject(entity: entity!, insertInto: backgroundContext)
            databaseHelper.setCoreDataObjectDataFromService(coreDataObject: coreService, newService: newService)
            
            var result: Bool = false
            backgroundContext.performAndWait {
                do {
                    try backgroundContext.save()
                    result = true
                } catch {
                }
            }
            
            return result
        } else {
            return false
        }
    }
    
    func getServiceFromDatabase(serviceId: Int64) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: SERVICES_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "idServicio = %f", argumentArray: [serviceId])
        var results: [NSManagedObject] = []
        
        mainContext.performAndWait {
            do {
                results = try mainContext.fetch(fetchRequest)
            } catch {
                print("Error checking the client in database")
            }
        }
        
        return results
    }
    
    func updateServiceInDatabase(service: ServiceModel) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: SERVICES_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "idServicio = %f", argumentArray: [service.serviceId])
        var results: [NSManagedObject] = []
        var result: Bool = false
        
        mainContext.performAndWait {
            do {
                results = try mainContext.fetch(fetchRequest)
                if results.count != 0 {
                    let coreService: NSManagedObject = results.first!
                    coreService.setValue(service.fecha, forKey: "fecha")
                    coreService.setValue(service.profesional, forKey: "profesional")
                    coreService.setValue(service.servicio, forKey: "servicio")
                    coreService.setValue(service.precio, forKey: "precio")
                    coreService.setValue(service.observacion, forKey: "observaciones")
                    
                    try mainContext.save()
                    result = true
                }
            } catch {
                print("Error checking the client in database")
            }
        }
        
        return result
    }
    
    func getServicesForDay(date: Date) -> [ServiceModel] {
        let beginningOfDay: Int64 = Int64(AgendaFunctions.getBeginningOfDayFromDate(date: date).timeIntervalSince1970)
        let endOfDay: Int64 = Int64(AgendaFunctions.getEndOfDayFromDate(date: date).timeIntervalSince1970)
        let allServices: [ServiceModel] = getAllServicesForDay(beginingOfDay: beginningOfDay, endOfDay: endOfDay)
        
        return allServices
    }
    
    func deleteService(service: ServiceModel) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: SERVICES_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "idServicio = %f", argumentArray: [service.serviceId])
        var results: [NSManagedObject] = []
        
        var result: Bool = false
        backgroundContext.performAndWait {
            do {
                results = try backgroundContext.fetch(fetchRequest)
                
                for object in results {
                    backgroundContext.delete(object)
                }
                
                try backgroundContext.save()
                result = true
            } catch {
            }
        }

        return result
    }
    
    func updateEmpleadoIdForServices(oldEmpleadoId: Int64, newEmpleadoId: Int64) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: SERVICES_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "profesional = %f", argumentArray: [oldEmpleadoId])
        var results: [NSManagedObject] = []
        
        backgroundContext.performAndWait {
            do {
                results = try backgroundContext.fetch(fetchRequest)
                
                for object in results {
                    object.setValue(newEmpleadoId, forKey: "profesional")
                }
                
                try backgroundContext.save()
            } catch {
            }
        }
    }
    
    func getServicesForEmpleado(empleadoId: Int64) -> [ServiceModel] {
        var services: [ServiceModel] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: SERVICES_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "profesional = %f", argumentArray: [empleadoId])
        
        mainContext.performAndWait {
            do {
                let results: [NSManagedObject] = try mainContext.fetch(fetchRequest)
                for data in results {
                    services.append(databaseHelper.parseServiceCoreObjectToServiceModel(coreObject: data))
                }
            } catch {
                print("Error checking the client in database")
            }
        }
        
        return services
    }
    
    func updateServicesForClientId(clientId: Int64) -> Bool {
        let client: ClientModel = Constants.databaseManager.clientsManager.getClientFromDatabase(clientId: clientId)!
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: SERVICES_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "idCliente = %f", argumentArray: [clientId])
        var result: Bool = false
        backgroundContext.performAndWait {
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                for object in results {
                    object.setValue(client.nombre, forKey: "nombre")
                    object.setValue(client.apellidos, forKey: "apellidos")
                }
                
                try backgroundContext.save()
                result = true
            } catch {
                result = false
            }
        }
        return result
    }
}
