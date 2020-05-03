//
//  ClientesJsonManager.swift
//  GestorHeme
//
//  Created by jon mikel on 27/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import Foundation

struct JsonClienteModel: Decodable {
    var Nombre: String!
    var Apellidos: String!
    var Direcion: String?
    var Telefono: String?
    var Fecha: String?
    var Servicio: String?
    var Comentarios: String?
    var Fecha2: String?
    var Servicio2: String?
    var Cumpleaños: String?
}

class ClientesJsonManager {
    static func parseClientesHeme() {
        do {
            if let path = Bundle.main.path(forResource: "clientesHeme", ofType: "json") {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let clientes: [JsonClienteModel] = try! JSONDecoder().decode([JsonClienteModel].self, from: data)
                createAppModelsFromJsonClientes(jsonClientes: clientes)
            }
        } catch {
           print("Error parsing json")
        }
    }
    
    private static func createAppModelsFromJsonClientes(jsonClientes: [JsonClienteModel]) {
        var clientes: [ClientModel] = []
        var servicios: [ServiceModel] = []
        var fecha: Date = Date(timeIntervalSince1970: 318330507)
        
        for jsonCliente in jsonClientes {
            let cliente: ClientModel = ClientModel()
            cliente.nombre = jsonCliente.Nombre
            cliente.id = Int64(fecha.timeIntervalSince1970)
            cliente.apellidos = jsonCliente.Apellidos
            cliente.direccion = jsonCliente.Direcion != nil ? jsonCliente.Direcion! : ""
            cliente.telefono = jsonCliente.Telefono != nil ? jsonCliente.Telefono! : ""
            cliente.fecha = jsonCliente.Cumpleaños != nil ? convertFechaToTimeStamp(fecha: jsonCliente.Cumpleaños!) : 0
            cliente.cadenciaVisita = Constants.dosSemanas
            cliente.observaciones = jsonCliente.Comentarios != nil ? jsonCliente.Comentarios! : ""
            clientes.append(cliente)
            
            _ = Constants.databaseManager.clientsManager.addClientToDatabase(newClient: cliente)
            //TODO actualizar funcionalidad
            //Constants.cloudDatabaseManager.clientManager.saveClient(client: cliente, showLoadingState: false)
            
            fecha = Calendar.current.date(byAdding: .hour, value: 1, to: fecha)!
            
            let servicio: ServiceModel = ServiceModel()
            servicio.serviceId = Int64(fecha.timeIntervalSince1970)
            servicio.clientId = cliente.id
            servicio.nombre = cliente.nombre
            servicio.apellidos = cliente.apellidos
            servicio.profesional = 651154318// Erregue
            servicio.fecha = jsonCliente.Fecha != nil ? convertFechaToTimeStamp(fecha: jsonCliente.Fecha!) : 0
            servicio.servicio = jsonCliente.Servicio != nil ? getServiceIdFromString(servicio: jsonCliente.Servicio!) : []
            servicio.observacion = jsonCliente.Servicio != nil ? jsonCliente.Servicio! :  ""
            servicios.append(servicio)
            
            _ = Constants.databaseManager.servicesManager.addServiceInDatabase(newService: servicio)

            //TODO revisar funcionalidad
            //Constants.cloudDatabaseManager.serviceManager.saveService(service: servicio, showLoadingState: false)
            
            fecha = Calendar.current.date(byAdding: .hour, value: 1, to: fecha)!
            
            if jsonCliente.Servicio2 != nil {
                let servicio2: ServiceModel = ServiceModel()
                servicio2.serviceId = Int64(fecha.timeIntervalSince1970)
                servicio2.clientId = cliente.id
                servicio2.nombre = cliente.nombre
                servicio2.apellidos = cliente.apellidos
                servicio2.profesional = 651154318//Erregue
                servicio2.fecha = convertFechaToTimeStamp(fecha: jsonCliente.Fecha2!)
                servicio2.servicio = getServiceIdFromString(servicio: jsonCliente.Servicio2!)
                servicio2.observacion = jsonCliente.Servicio2!
                servicios.append(servicio2)
                
                _ = Constants.databaseManager.servicesManager.addServiceInDatabase(newService: servicio2)
                //TODO revisar funcionalidad
                //Constants.cloudDatabaseManager.serviceManager.saveService(service: servicio2, showLoadingState: false)
            }
            
            fecha = Calendar.current.date(byAdding: .hour, value: 1, to: fecha)!
        }
    }
    
    private static func convertFechaToTimeStamp(fecha: String) -> Int64 {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_ES")
        dateFormatter.dateFormat = "MM/dd/yy"
        return Int64(dateFormatter.date(from:fecha)!.timeIntervalSince1970)
    }
    
    private static func getServiceIdFromString(servicio: String) -> [Int64] {
        let tipoServicios: [TipoServicioModel] = Constants.databaseManager.tipoServiciosManager.getAllServiciosFromDatabase()
        var servicioIds: [Int64] = []
        for tipoServicio in tipoServicios {
            if tipoServicio.nombre.contains(servicio) {
                servicioIds.append(tipoServicio.servicioId)
            }
        }
        
        return servicioIds
    }
}
