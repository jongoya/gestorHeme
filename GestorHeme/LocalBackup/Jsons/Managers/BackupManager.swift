//
//  BackupManager.swift
//  GestorHeme
//
//  Created by jon mikel on 27/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import Foundation

//TODO, pendiente de revisar el backup local
class BackupManager {
    
    static func buildBackupJson() {
        var contadorCliente: Int = 0
        
        let clientes: [ClientModel] = Constants.databaseManager.clientsManager.getAllClientsFromDatabase()
        var json: [String : Any] = [:]
        var clientArray: [[String : Any]] = []
        var servicesArray: [[String : Any]] = []
        var empleadosArray: [[String : Any]] = []
        var tipoServiciosArray: [[String : Any]] = []
        for client in clientes {
            let dictionary: [String : Any] = ["id" : client.id, "nombre" : client.nombre, "apellidos" : client.apellidos, "fecha" : client.fecha, "telefono" : client.telefono, "email" : client.email, "direccion" : client.direccion, "cadenciaVisita" : client.cadenciaVisita, "observaciones" : client.observaciones, "notificacionPersonalizada" : client.notificacionPersonalizada]
            clientArray.append(dictionary)
            
            contadorCliente = contadorCliente + 1
        }
        
        let servicios: [ServiceModel] = Constants.databaseManager.servicesManager.getAllServicesFromDatabase()
        for service in servicios {
            let dictionary: [String : Any] = ["clientId" : service.clientId, "serviceId" : service.serviceId, "nombre" : service.nombre, "apellidos" : service.apellidos, "fecha" : service.fecha, "profesional" : service.profesional, "servicio" : service.servicio, "observacion" : service.observacion]
            servicesArray.append(dictionary)
        }
        
        let empleados: [EmpleadoModel] = Constants.databaseManager.empleadosManager.getAllEmpleadosFromDatabase()
        for empleado in empleados {
            let dictionary: [String : Any] = ["nombre" : empleado.nombre, "apellidos" : empleado.apellidos, "fecha" : empleado.fecha, "telefono" : empleado.telefono, "email" : empleado.email, "empleadoId" : empleado.empleadoId, "redColorValue" : empleado.redColorValue, "greenColorValue" : empleado.greenColorValue, "blueColorValue" : empleado.blueColorValue]
            empleadosArray.append(dictionary)
        }
        
        let tipoServicios: [TipoServicioModel] = Constants.databaseManager.tipoServiciosManager.getAllServiciosFromDatabase()
        for tipoServicio in tipoServicios {
            let dictionary: [String : Any] = ["nombre" : tipoServicio.nombre, "servicioId" : tipoServicio.servicioId]
            tipoServiciosArray.append(dictionary)
        }
        
        json["Clientes"] = clientArray
        json["Servicios"] = servicesArray
        json["Empleados"] = empleadosArray
        json["TipoServicios"] = tipoServiciosArray
        
        do {
            if let jsonData = try JSONSerialization.data(withJSONObject: json, options: .init(rawValue: 0)) as? Data {
                print(NSString(data: jsonData, encoding: 1)!)
                print("NUMERO DE CLIENTES EN EL BACKUP: " + String(contadorCliente))
                print("")
            }
        } catch {
            print("")
        }
        

    }
}

