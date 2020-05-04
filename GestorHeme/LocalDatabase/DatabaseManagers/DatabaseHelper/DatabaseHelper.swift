//
//  DatabaseHelper.swift
//  GestorHeme
//
//  Created by jon mikel on 01/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import CoreData

class DatabaseHelper: NSObject {
    
    func parseClientCoreObjectToClientModel(coreObject: NSManagedObject) -> ClientModel {
        let client: ClientModel = ClientModel()
        client.id = coreObject.value(forKey: "idCliente") as! Int64
        client.nombre = coreObject.value(forKey: "nombre") as! String
        client.apellidos = coreObject.value(forKey: "apellidos") as! String
        client.fecha = coreObject.value(forKey: "fecha") as! Int64
        client.email = coreObject.value(forKey: "email") as! String
        client.telefono = coreObject.value(forKey: "telefono") as! String
        client.direccion = coreObject.value(forKey: "direccion") as! String
        client.cadenciaVisita = coreObject.value(forKey: "cadenciaVisita") as! String
        client.observaciones = coreObject.value(forKey: "observaciones") as! String
        client.notificacionPersonalizada = coreObject.value(forKey: "notificacionPersonalizada") as! Int64
        client.imagen = coreObject.value(forKey: "imagen") as! String
        
        return client
    }
    
    func setCoreDataObjectDataFromClient(coreDataObject: NSManagedObject, newClient: ClientModel) {
        coreDataObject.setValue(newClient.id, forKey: "idCliente")
        coreDataObject.setValue(newClient.nombre, forKey: "nombre")
        coreDataObject.setValue(newClient.apellidos, forKey: "apellidos")
        coreDataObject.setValue(newClient.fecha, forKey: "fecha")
        coreDataObject.setValue(newClient.email, forKey: "email")
        coreDataObject.setValue(newClient.telefono, forKey: "telefono")
        coreDataObject.setValue(newClient.direccion, forKey: "direccion")
        coreDataObject.setValue(newClient.cadenciaVisita, forKey: "cadenciaVisita")
        coreDataObject.setValue(newClient.observaciones, forKey: "observaciones")
        coreDataObject.setValue(newClient.notificacionPersonalizada, forKey: "notificacionPersonalizada")
        coreDataObject.setValue(newClient.imagen, forKey: "imagen")
    }
    
    func parseServiceCoreObjectToServiceModel(coreObject: NSManagedObject) -> ServiceModel {
        let service: ServiceModel = ServiceModel()
        service.clientId = coreObject.value(forKey: "idCliente") as! Int64
        service.serviceId = coreObject.value(forKey: "idServicio") as! Int64
        service.nombre = coreObject.value(forKey: "nombre") as! String
        service.apellidos = coreObject.value(forKey: "apellidos") as! String
        service.fecha = coreObject.value(forKey: "fecha") as! Int64
        service.profesional = coreObject.value(forKey: "profesional") as! Int64
        service.servicio = coreObject.value(forKey: "servicio") as! [Int64]
        service.precio = coreObject.value(forKey: "precio") as! Double
        service.observacion = coreObject.value(forKey: "observaciones") as! String
        
        return service
    }
    
    func setCoreDataObjectDataFromService(coreDataObject: NSManagedObject, newService: ServiceModel) {
        coreDataObject.setValue(newService.serviceId, forKey: "idServicio")
        coreDataObject.setValue(newService.clientId, forKey: "idCliente")
        coreDataObject.setValue(newService.nombre, forKey: "nombre")
        coreDataObject.setValue(newService.apellidos, forKey: "apellidos")
        coreDataObject.setValue(newService.fecha, forKey: "fecha")
        coreDataObject.setValue(newService.profesional, forKey: "profesional")
        coreDataObject.setValue(newService.servicio, forKey: "servicio")
        coreDataObject.setValue(newService.precio, forKey: "precio")
        coreDataObject.setValue(newService.observacion, forKey: "observaciones")
    }
    
    func updateClientObject(coreClient: NSManagedObject, client: ClientModel) {
        coreClient.setValue(client.nombre, forKey: "nombre")
        coreClient.setValue(client.apellidos, forKey: "apellidos")
        coreClient.setValue(client.fecha, forKey: "fecha")
        coreClient.setValue(client.telefono, forKey: "telefono")
        coreClient.setValue(client.email, forKey: "email")
        coreClient.setValue(client.direccion, forKey: "direccion")
        coreClient.setValue(client.cadenciaVisita, forKey: "cadenciaVisita")
        coreClient.setValue(client.observaciones, forKey: "observaciones")
        coreClient.setValue(client.notificacionPersonalizada, forKey: "notificacionPersonalizada")
        coreClient.setValue(client.imagen, forKey: "imagen")
    }
    
    func parseNotificationCoreObjectToNotificationModel(coreObject: NSManagedObject) -> NotificationModel {
        let notification: NotificationModel = NotificationModel()
        notification.clientId = coreObject.value(forKey: "clientId") as! [Int64]
        notification.notificationId = coreObject.value(forKey: "notificationId") as! Int64
        notification.descripcion = coreObject.value(forKey: "descripcion") as! String
        notification.fecha = coreObject.value(forKey: "fecha") as! Int64
        notification.leido = coreObject.value(forKey: "leido") as! Bool
        notification.type = coreObject.value(forKey: "type") as! String
        
        return notification
    }
    
    func setCoreDataObjectDataFromNotification(coreDataObject: NSManagedObject, newNotification: NotificationModel) {
        coreDataObject.setValue(newNotification.clientId, forKey: "clientId")
        coreDataObject.setValue(newNotification.notificationId, forKey: "notificationId")
        coreDataObject.setValue(newNotification.descripcion, forKey: "descripcion")
        coreDataObject.setValue(newNotification.fecha, forKey: "fecha")
        coreDataObject.setValue(newNotification.leido, forKey: "leido")
        coreDataObject.setValue(newNotification.type, forKey: "type")
    }
    
    func parseEmpleadosCoreObjectToEmpleadosModel(coreObject: NSManagedObject) -> EmpleadoModel {
        let empleado: EmpleadoModel = EmpleadoModel()
        empleado.empleadoId = coreObject.value(forKey: "empleadoId") as! Int64
        empleado.nombre = coreObject.value(forKey: "nombre") as! String
        empleado.apellidos = coreObject.value(forKey: "apellidos") as! String
        empleado.fecha = coreObject.value(forKey: "fecha") as! Int64
        empleado.telefono = coreObject.value(forKey: "telefono") as! String
        empleado.email = coreObject.value(forKey: "email") as! String
        empleado.redColorValue = coreObject.value(forKey: "redColorValue") as! Float
        empleado.greenColorValue = coreObject.value(forKey: "greenColorValue") as! Float
        empleado.blueColorValue = coreObject.value(forKey: "blueColorValue") as! Float
        
        return empleado
    }
    
    func setCoreDataObjectDataFromEmpleado(coreDataObject: NSManagedObject, newEmpleado: EmpleadoModel) {
        coreDataObject.setValue(newEmpleado.empleadoId, forKey: "empleadoId")
        coreDataObject.setValue(newEmpleado.nombre, forKey: "nombre")
        coreDataObject.setValue(newEmpleado.apellidos, forKey: "apellidos")
        coreDataObject.setValue(newEmpleado.fecha, forKey: "fecha")
        coreDataObject.setValue(newEmpleado.telefono, forKey: "telefono")
        coreDataObject.setValue(newEmpleado.email, forKey: "email")
        coreDataObject.setValue(newEmpleado.redColorValue, forKey: "redColorValue")
        coreDataObject.setValue(newEmpleado.greenColorValue, forKey: "greenColorValue")
        coreDataObject.setValue(newEmpleado.blueColorValue, forKey: "blueColorValue")
    }
    
    func parseTipoServiciosCoreObjectToTipoServicioModel(coreObject: NSManagedObject) -> TipoServicioModel {
        let servicio: TipoServicioModel = TipoServicioModel()
        servicio.servicioId = coreObject.value(forKey: "servicioId") as! Int64
        servicio.nombre = coreObject.value(forKey: "nombre") as! String
        
        return servicio
    }
    
    func setCoreDataObjectDataFromTipoServicio(coreDataObject: NSManagedObject, newServicio: TipoServicioModel) {
        coreDataObject.setValue(newServicio.servicioId, forKey: "servicioId")
        coreDataObject.setValue(newServicio.nombre, forKey: "nombre")
    }
    
    func parseCierreCajaCoreObjectToCierreCajaModel(coreObject: NSManagedObject) -> CierreCajaModel {
        let cierreCaja: CierreCajaModel = CierreCajaModel()
        cierreCaja.cajaId = coreObject.value(forKey: "cajaId") as! Int64
        cierreCaja.fecha = coreObject.value(forKey: "fecha") as! Int64
        cierreCaja.numeroServicios = coreObject.value(forKey: "numeroServicios") as! Int
        cierreCaja.totalCaja = coreObject.value(forKey: "totalCaja") as! Double
        cierreCaja.totalProductos = coreObject.value(forKey: "totalProductos") as! Double
        cierreCaja.efectivo = coreObject.value(forKey: "efectivo") as! Double
        cierreCaja.tarjeta = coreObject.value(forKey: "tarjeta") as! Double
        
        return cierreCaja
    }
    
    func setCoreDataObjectDataFromCierreCaja(coreDataObject: NSManagedObject, newCierreCaja: CierreCajaModel) {
        coreDataObject.setValue(newCierreCaja.cajaId, forKey: "cajaId")
        coreDataObject.setValue(newCierreCaja.fecha, forKey: "fecha")
        coreDataObject.setValue(newCierreCaja.numeroServicios, forKey: "numeroServicios")
        coreDataObject.setValue(newCierreCaja.totalCaja, forKey: "totalCaja")
        coreDataObject.setValue(newCierreCaja.totalProductos, forKey: "totalProductos")
        coreDataObject.setValue(newCierreCaja.efectivo, forKey: "efectivo")
        coreDataObject.setValue(newCierreCaja.tarjeta, forKey: "tarjeta")
    }
}
