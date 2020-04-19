//
//  EmpleadosManager.swift
//  GestorHeme
//
//  Created by jon mikel on 12/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import  CoreData

class EmpleadosManager: NSObject {
    let EMPLEADOS_ENTITY_NAME: String = "Empleado"
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
    
    func getAllEmpleadosFromDatabase() -> [EmpleadoModel] {
        var empleados: [EmpleadoModel] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EMPLEADOS_ENTITY_NAME)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results: [NSManagedObject] = try mainContext.fetch(fetchRequest)
            for data in results {
                empleados.append(databaseHelper.parseEmpleadosCoreObjectToEmpleadosModel(coreObject: data))
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return empleados
    }
    
    func addEmpleadoToDatabase(newEmpleado: EmpleadoModel) -> Bool {
        let entity = NSEntityDescription.entity(forEntityName: EMPLEADOS_ENTITY_NAME, in: backgroundContext)
        
        if getCoreEmpleadoFromDatabase(empleadoId: newEmpleado.empleadoId).count == 0 {
            let coreService = NSManagedObject(entity: entity!, insertInto: backgroundContext)
            databaseHelper.setCoreDataObjectDataFromEmpleado(coreDataObject: coreService, newEmpleado: newEmpleado)
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
    
    func getCoreEmpleadoFromDatabase(empleadoId: Int64) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EMPLEADOS_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "empleadoId = %f", argumentArray: [empleadoId])
        var results: [NSManagedObject] = []
        
        do {
            results = try mainContext.fetch(fetchRequest)
        } catch {
            print("Error checking the client in database")
        }
        
        return results
    }
    
    func getEmpleadoFromDatabase(empleadoId: Int64) -> EmpleadoModel {
        let coreEmpleados: [NSManagedObject] = getCoreEmpleadoFromDatabase(empleadoId: empleadoId)
        
        return databaseHelper.parseEmpleadosCoreObjectToEmpleadosModel(coreObject: coreEmpleados.first!)
    }
    
    func updateEmpleado(empleado: EmpleadoModel) -> Bool {
        let empleados: [NSManagedObject] = getCoreEmpleadoFromDatabase(empleadoId: empleado.empleadoId)
        
        if empleados.count == 0 {
            return false
        }
        
        let coreEmpleado: NSManagedObject = empleados.first!
        coreEmpleado.setValue(empleado.redColorValue, forKey: "redColorValue")
        coreEmpleado.setValue(empleado.greenColorValue, forKey: "greenColorValue")
        coreEmpleado.setValue(empleado.blueColorValue, forKey: "blueColorValue")
        coreEmpleado.setValue(empleado.nombre, forKey: "nombre")
        coreEmpleado.setValue(empleado.apellidos, forKey: "apellidos")
        coreEmpleado.setValue(empleado.fecha, forKey: "fecha")
        coreEmpleado.setValue(empleado.telefono, forKey: "telefono")
        coreEmpleado.setValue(empleado.email, forKey: "email")
        
        do {
            try mainContext.save()
            return true
        } catch {
            return false
        }
    }
    
    func eliminarEmpleado(empleadoId: Int64) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EMPLEADOS_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "empleadoId = %f", argumentArray: [empleadoId])
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
