//
//  TipoServiciosManager.swift
//  GestorHeme
//
//  Created by jon mikel on 12/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import CoreData

class TipoServiciosManager: NSObject {
    let TIPOSERVICIOS_ENTITY_NAME: String = "TipoServicios"
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
    
    func getAllServiciosFromDatabase() -> [TipoServicioModel] {
        var servicios: [TipoServicioModel] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: TIPOSERVICIOS_ENTITY_NAME)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results: [NSManagedObject] = try mainContext.fetch(fetchRequest)
            for data in results {
                servicios.append(databaseHelper.parseTipoServiciosCoreObjectToTipoServicioModel(coreObject: data))
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return servicios
    }
    
    func addTipoServicioToDatabase(servicio: TipoServicioModel) -> Bool {
        let entity = NSEntityDescription.entity(forEntityName: TIPOSERVICIOS_ENTITY_NAME, in: backgroundContext)
        
        if getCoreTipoServicioFromDatabase(servicioId: servicio.servicioId).count == 0 {
            let coreService = NSManagedObject(entity: entity!, insertInto: backgroundContext)
            databaseHelper.setCoreDataObjectDataFromTipoServicio(coreDataObject: coreService, newServicio: servicio)
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
    
    private func getCoreTipoServicioFromDatabase(servicioId: Int64) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: TIPOSERVICIOS_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "servicioId = %f", argumentArray: [servicioId])
        var results: [NSManagedObject] = []
        
        do {
            results = try mainContext.fetch(fetchRequest)
        } catch {
            print("Error checking the client in database")
        }
        
        return results
    }
    
    func getTipoServicioFromDatabase(servicioId: Int64) -> TipoServicioModel {
        let coreTipoServicios: [NSManagedObject] = getCoreTipoServicioFromDatabase(servicioId: servicioId)
        
        return databaseHelper.parseTipoServiciosCoreObjectToTipoServicioModel(coreObject: coreTipoServicios.first!)
    }
    
    func eliminarServicios() -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: TIPOSERVICIOS_ENTITY_NAME)
        //fetchRequest.predicate = NSPredicate(format: "empleadoId = %f", argumentArray: [empleadoId])
        var results: [NSManagedObject] = []
        
        do {
            results = try backgroundContext.fetch(fetchRequest)
            
            if results.count == 0 {
                return false
            }
            
            for object in results {
                backgroundContext.delete(object)
            }
            
            try backgroundContext.save()
            return true
        } catch {
            return false
        }
    }
}
