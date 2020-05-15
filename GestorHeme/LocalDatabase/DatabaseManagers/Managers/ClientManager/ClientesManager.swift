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
        mainContext.performAndWait {
            do {
                let results: [NSManagedObject] = try mainContext.fetch(fetchRequest)
                for data in results {
                    clientes.append(databaseHelper.parseClientCoreObjectToClientModel(coreObject: data))
                }
            } catch {
            }
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
    
    func getCoreClientFromDatabase(clientId: Int64) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CLIENTES_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "idCliente = %f", argumentArray: [clientId])
        var results: [NSManagedObject] = []
        mainContext.performAndWait {
            do {
                results = try mainContext.fetch(fetchRequest)
            } catch {
            }
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
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CLIENTES_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "idCliente = %f", argumentArray: [client.id])
        var results: [NSManagedObject] = []
        var result: Bool = false
        
        mainContext.performAndWait {
            do {
                results = try mainContext.fetch(fetchRequest)
                
                if results.count != 0 {
                    let coreClient: NSManagedObject = results.first!
                    databaseHelper.updateClientObject(coreClient: coreClient, client: client)
                    try mainContext.save()
                    result = true
                }
            } catch {
            }
        }
        
        return result
    }
}
