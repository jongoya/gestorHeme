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
        
        mainContext.performAndWait {
            do {
                let results: [NSManagedObject] = try mainContext.fetch(fetchRequest)
                for data in results {
                    empleados.append(databaseHelper.parseEmpleadosCoreObjectToEmpleadosModel(coreObject: data))
                }
            } catch {
            }
        }
        
        return empleados
    }
    
    func addEmpleadoToDatabase(newEmpleado: EmpleadoModel) -> Bool {
        let entity = NSEntityDescription.entity(forEntityName: EMPLEADOS_ENTITY_NAME, in: backgroundContext)
        
        if getCoreEmpleadoFromDatabase(empleadoId: newEmpleado.empleadoId).count == 0 {
            let coreService = NSManagedObject(entity: entity!, insertInto: backgroundContext)
            databaseHelper.setCoreDataObjectDataFromEmpleado(coreDataObject: coreService, newEmpleado: newEmpleado)
            
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
    
    func getCoreEmpleadoFromDatabase(empleadoId: Int64) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EMPLEADOS_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "empleadoId = %f", argumentArray: [empleadoId])
        var results: [NSManagedObject] = []
        
        mainContext.performAndWait {
            do {
                results = try mainContext.fetch(fetchRequest)
            } catch {
            }
        }
        
        return results
    }
    
    func getEmpleadoFromDatabase(empleadoId: Int64) -> EmpleadoModel? {
        let coreEmpleados: [NSManagedObject] = getCoreEmpleadoFromDatabase(empleadoId: empleadoId)
        
        if coreEmpleados.count == 0 {
            return nil
        }
        
        return databaseHelper.parseEmpleadosCoreObjectToEmpleadosModel(coreObject: coreEmpleados.first!)
    }
    
    func updateEmpleado(empleado: EmpleadoModel) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EMPLEADOS_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "empleadoId = %f", argumentArray: [empleado.empleadoId])
        var results: [NSManagedObject] = []
        var result: Bool = false
        
        mainContext.performAndWait {
            do {
                results = try mainContext.fetch(fetchRequest)
                
                if results.count != 0 {
                    let coreEmpleado: NSManagedObject = results.first!
                    coreEmpleado.setValue(empleado.redColorValue, forKey: "redColorValue")
                    coreEmpleado.setValue(empleado.greenColorValue, forKey: "greenColorValue")
                    coreEmpleado.setValue(empleado.blueColorValue, forKey: "blueColorValue")
                    coreEmpleado.setValue(empleado.nombre, forKey: "nombre")
                    coreEmpleado.setValue(empleado.apellidos, forKey: "apellidos")
                    coreEmpleado.setValue(empleado.fecha, forKey: "fecha")
                    coreEmpleado.setValue(empleado.telefono, forKey: "telefono")
                    coreEmpleado.setValue(empleado.email, forKey: "email")
                    try mainContext.save()
                    result = true
                }
            } catch {
            }
        }
        
        return result
    }
    
    func eliminarEmpleado(empleadoId: Int64) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EMPLEADOS_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "empleadoId = %f", argumentArray: [empleadoId])
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
}
