//
//  CajaManager.swift
//  GestorHeme
//
//  Created by jon mikel on 21/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import CoreData

class CierreCajaManager: NSObject {
    let CAJA_ENTITY_NAME: String = "Caja"
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
    
    func getAllCierreCajasFromDatabase() -> [CierreCajaModel] {
        var cierreCajas: [CierreCajaModel] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CAJA_ENTITY_NAME)
        fetchRequest.returnsObjectsAsFaults = false
        mainContext.performAndWait {
            do {
                let results: [NSManagedObject] = try mainContext.fetch(fetchRequest)
                for data in results {
                    cierreCajas.append(databaseHelper.parseCierreCajaCoreObjectToCierreCajaModel(coreObject: data))
                }
            } catch {
            }
        }
    
        return cierreCajas
    }
    
    func getAllCierreCajasForEstadisticas(date: Date, isMonth: Bool, isTotal: Bool) -> [CierreCajaModel] {
        var cierreCajas: [CierreCajaModel] = []
        if isTotal {
            return getAllCierreCajasFromDatabase()
        }
        
        var fechaInicio: Int64 = Int64(AgendaFunctions.getBeginingOfMonthFromDate(date: date).timeIntervalSince1970)
        var fechaFin: Int64 = Int64(AgendaFunctions.getEndOfMonthFromDate(date: date).timeIntervalSince1970)
        
        if !isMonth {
            fechaInicio = Int64(AgendaFunctions.getBeginingOfYearFromDate(date: date).timeIntervalSince1970)
            fechaFin = Int64(AgendaFunctions.getEndOfYearFromDate(date: date).timeIntervalSince1970)
        }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CAJA_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "fecha > %d AND fecha < %d", argumentArray: [fechaInicio, fechaFin])
        mainContext.performAndWait {
            do {
                let results: [NSManagedObject] = try mainContext.fetch(fetchRequest)
                for data in results {
                    cierreCajas.append(databaseHelper.parseCierreCajaCoreObjectToCierreCajaModel(coreObject: data))
                }
            } catch {
            }
        }
        
        return cierreCajas
    }
    
    func addCierreCajaToDatabase(newCierreCaja: CierreCajaModel) -> Bool {
        let entity = NSEntityDescription.entity(forEntityName: CAJA_ENTITY_NAME, in: backgroundContext)
        
        if getCoreCierreCajaFromDatabase(cajaId: newCierreCaja.cajaId).count == 0 {
            let cierreCaja = NSManagedObject(entity: entity!, insertInto: backgroundContext)
            databaseHelper.setCoreDataObjectDataFromCierreCaja(coreDataObject: cierreCaja, newCierreCaja: newCierreCaja)
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
    
    func getCoreCierreCajaFromDatabase(cajaId: Int64) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CAJA_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "cajaId = %f", argumentArray: [cajaId])
        var results: [NSManagedObject] = []
        mainContext.performAndWait {
            do {
                results = try mainContext.fetch(fetchRequest)
            } catch {
            }
        }
        
        return results
    }
    
    func checkCierreCajaInDatabase(fecha: Date) -> Bool {
        let beginingOfDate: Int64 = Int64(AgendaFunctions.getBeginningOfDayFromDate(date: fecha).timeIntervalSince1970)
        let endOfDay: Int64 = Int64(AgendaFunctions.getEndOfDayFromDate(date: fecha).timeIntervalSince1970)
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CAJA_ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "fecha > %d AND fecha < %d", argumentArray: [beginingOfDate, endOfDay])
        var results: [NSManagedObject] = []
        mainContext.performAndWait {
            do {
                results = try mainContext.fetch(fetchRequest)
            } catch {
            }
        }
        
        return results.count > 0
    }
}
