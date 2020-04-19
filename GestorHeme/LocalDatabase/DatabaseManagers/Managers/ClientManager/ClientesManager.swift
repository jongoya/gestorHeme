//
//  ClientesManager.swift
//  GestorHeme
//
//  Created by jon mikel on 31/03/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import  CoreData

class ClientesManager: NSObject {
    let CLIENTES_ENTITY_NAME: String = "Cliente"
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

    func getAllClientsFromDatabase() -> [ClientModel] {
        var clientes: [ClientModel] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CLIENTES_ENTITY_NAME)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results: [NSManagedObject] = try mainContext.fetch(fetchRequest)
            for data in results {
                clientes.append(databaseHelper.parseClientCoreObjectToClientModel(coreObject: data))
            }
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return clientes
    }
    
    func getClientsFilteredByText(text: String) -> [ClientModel] {
        var filteredArray: [ClientModel] = []
        let clients: [ClientModel] = getAllClientsFromDatabase()
        for client: ClientModel in clients {
            let completeName: String = client.nombre.lowercased() + " " + client.apellidos.lowercased()
            if completeName.contains(text.lowercased()) {
                filteredArray.append(client)
            }
        }
        
        return filteredArray
    }
    
    func addClientToDatabase(newClient: ClientModel) -> Bool {
        let entity = NSEntityDescription.entity(forEntityName: CLIENTES_ENTITY_NAME, in: backgroundContext)
        
        if getCoreClientFromDatabase(clientId: newClient.id).count == 0 {
            let client = NSManagedObject(entity: entity!, insertInto: backgroundContext)
            databaseHelper.setCoreDataObjectDataFromClient(coreDataObject: client, newClient: newClient)
            do {
                try backgroundContext.save()
                return true
            } catch {
                return false
            }
        } else {
            return false
        }
    }
    
    func getCoreClientFromDatabase(clientId: Int64) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CLIENTES_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "idCliente = %f", argumentArray: [clientId])
        var results: [NSManagedObject] = []
        
        do {
            results = try mainContext.fetch(fetchRequest)
        } catch {
            print("Error checking the client in database")
        }
        
        return results
    }
    
    func getClientFromDatabase(clientId: Int64) -> ClientModel? {
        let coreClients: [NSManagedObject] =  getCoreClientFromDatabase(clientId: clientId)
        if coreClients.count == 0 {
            return nil
        }
        
        return databaseHelper.parseClientCoreObjectToClientModel(coreObject: coreClients.first!)
    }
    
    func updateClientInDatabase(client: ClientModel) -> Bool {
        let clients: [NSManagedObject] = getCoreClientFromDatabase(clientId: client.id)
        
        if clients.count == 0 {
            return false
        }
        
        let coreClient: NSManagedObject = clients.first!
        databaseHelper.updateClientObject(coreClient: coreClient, client: client)
        
        let services: [ServiceModel] = Constants.databaseManager.servicesManager.getServicesForClientId(clientId: client.id)
        
        for service: ServiceModel in services {
            if !Constants.databaseManager.servicesManager.updateNombreYApellidosToService(serviceId: service.serviceId, client: client) {
                return false
            }
            
            Constants.cloudDatabaseManager.serviceManager.updateService(service: service, showLoadingState: false)
        }
        
        do {
            try mainContext.save()
            return true
        } catch {
            return false
        }
    }
}
