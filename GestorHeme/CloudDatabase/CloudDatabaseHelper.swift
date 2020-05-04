//
//  CloudDatabaseHelper.swift
//  GestorHeme
//
//  Created by jon mikel on 16/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import CloudKit

class CloudDatabaseHelper: NSObject {

    func parseCloudCLientObjectToLocalCLientObject(record: CKRecord) -> ClientModel {
        let cliente: ClientModel = ClientModel()
        cliente.nombre = record.object(forKey: "CD_nombre") as! String
        cliente.apellidos = record.object(forKey: "CD_apellidos") as! String
        cliente.id = record.object(forKey: "CD_idCliente") as! Int64
        cliente.fecha = record.object(forKey: "CD_fecha") as! Int64
        cliente.telefono = record.object(forKey: "CD_telefono") as! String
        cliente.email = record.object(forKey: "CD_email") as! String
        cliente.direccion = record.object(forKey: "CD_direccion") as! String
        cliente.cadenciaVisita = record.object(forKey: "CD_cadenciaVisita") as! String
        cliente.observaciones = record.object(forKey: "CD_observaciones") as! String
        cliente.notificacionPersonalizada = record.object(forKey: "CD_notificacionPersonalizada") as! Int64
        cliente.imagen = record.object(forKey: "CD_imagen") as? String ?? ""
        
        return cliente
    }
    
    func parseCloudEmpleadoObjectToLocalEmpleadoObject(record: CKRecord) -> EmpleadoModel {
        let empleado: EmpleadoModel = EmpleadoModel()
        empleado.nombre = record.object(forKey: "CD_nombre") as! String
        empleado.apellidos = record.object(forKey: "CD_apellidos") as! String
        empleado.fecha = record.object(forKey: "CD_fecha") as! Int64
        empleado.telefono = record.object(forKey: "CD_telefono") as! String
        empleado.email = record.object(forKey: "CD_email") as! String
        empleado.empleadoId = record.object(forKey: "CD_empleadoId") as! Int64
        empleado.redColorValue = (record.object(forKey: "CD_redColorValue") as! NSNumber).floatValue
        empleado.greenColorValue = (record.object(forKey: "CD_greenColorValue") as! NSNumber).floatValue
        empleado.blueColorValue = (record.object(forKey: "CD_blueColorValue") as! NSNumber).floatValue
        
        return empleado
    }
    
    func parseCloudTipoServicioObjectToLocalTipoServicioObject(record: CKRecord) -> TipoServicioModel {
        let tipoServicio: TipoServicioModel = TipoServicioModel()
        tipoServicio.nombre = record.object(forKey: "CD_nombre") as! String
        tipoServicio.servicioId = record.object(forKey: "CD_servicioId") as! Int64
        
        return tipoServicio
    }
    
    func parseCloudNotificationsObjectToLocalNotificationObject(record: CKRecord) -> NotificationModel {
        let notification: NotificationModel = NotificationModel()
        notification.clientId = record.object(forKey: "CD_clientId") as? [Int64] ?? []
        notification.notificationId = record.object(forKey: "CD_notificationId") as! Int64
        notification.descripcion = record.object(forKey: "CD_descripcion") as! String
        notification.fecha = record.object(forKey: "CD_fecha") as! Int64
        notification.leido = record.object(forKey: "CD_leido") as! Bool
        notification.type = record.object(forKey: "CD_type") as! String
        
        return notification
    }
    
    func parseCloudServicioObjectToLocalServicioObject(record: CKRecord) -> ServiceModel {
        let servicio: ServiceModel = ServiceModel()
        servicio.clientId = record.object(forKey: "CD_clientId") as! Int64
        servicio.serviceId = record.object(forKey: "CD_serviceId") as! Int64
        servicio.nombre = record.object(forKey: "CD_nombre") as! String
        servicio.apellidos = record.object(forKey: "CD_apellidos") as! String
        servicio.fecha = record.object(forKey: "CD_fecha") as! Int64
        servicio.profesional = record.object(forKey: "CD_profesional") as! Int64
        servicio.servicio = record.object(forKey: "CD_servicios") as! [Int64]
        servicio.observacion = record.object(forKey: "CD_observacion") as! String
        servicio.precio = record.object(forKey: "CD_precio") as? Double ?? 0.0
        
        return servicio
    }
    
    func parseCloudCierreCajaObjectToLocalCierreCajaObject(record: CKRecord) -> CierreCajaModel {
        let cierreCaja: CierreCajaModel = CierreCajaModel()
        cierreCaja.cajaId = record.object(forKey: "CD_cajaId") as! Int64
        cierreCaja.fecha = record.object(forKey: "CD_fecha") as! Int64
        cierreCaja.numeroServicios = record.object(forKey: "CD_numeroServicios") as! Int
        cierreCaja.totalCaja = record.object(forKey: "CD_totalCaja") as! Double
        cierreCaja.totalProductos = record.object(forKey: "CD_totalProductos") as! Double
        cierreCaja.efectivo = record.object(forKey: "CD_efectivo") as! Double
        cierreCaja.tarjeta = record.object(forKey: "CD_tarjeta") as! Double
        
        return cierreCaja
    }
    
    func setClientCKRecordVariables(client: ClientModel, record: CKRecord) {
        record.setValue(client.nombre, forKey: "CD_nombre")
        record.setValue(client.apellidos, forKey: "CD_apellidos")
        record.setValue(client.id, forKey: "CD_idCliente")
        record.setValue(client.fecha, forKey: "CD_fecha")
        record.setValue(client.telefono, forKey: "CD_telefono")
        record.setValue(client.email, forKey: "CD_email")
        record.setValue(client.direccion, forKey: "CD_direccion")
        record.setValue(client.cadenciaVisita, forKey: "CD_cadenciaVisita")
        record.setValue(client.observaciones, forKey: "CD_observaciones")
        record.setValue(client.notificacionPersonalizada, forKey: "CD_notificacionPersonalizada")
        record.setValue(client.imagen, forKey: "CD_imagen")
    }
    
    func setEmpleadoCKRecordVariables(empleado: EmpleadoModel, record: CKRecord) {
        record.setValue(empleado.nombre, forKey: "CD_nombre")
        record.setValue(empleado.apellidos, forKey: "CD_apellidos")
        record.setValue(empleado.empleadoId, forKey: "CD_empleadoId")
        record.setValue(empleado.fecha, forKey: "CD_fecha")
        record.setValue(empleado.telefono, forKey: "CD_telefono")
        record.setValue(empleado.email, forKey: "CD_email")
        record.setValue(empleado.redColorValue, forKey: "CD_redColorValue")
        record.setValue(empleado.greenColorValue, forKey: "CD_greenColorValue")
        record.setValue(empleado.blueColorValue, forKey: "CD_blueColorValue")
    }
    
    func setTipoServicioCKRecordVariables(tipoServicio: TipoServicioModel, record: CKRecord) {
        record.setValue(tipoServicio.nombre, forKey: "CD_nombre")
        record.setValue(tipoServicio.servicioId, forKey: "CD_servicioId")
    }
    
    func setNotificationCKRecordVariables(notification: NotificationModel, record: CKRecord) {
        record.setValue(notification.clientId, forKey: "CD_clientId")
        record.setValue(notification.notificationId, forKey: "CD_notificationId")
        record.setValue(notification.descripcion, forKey: "CD_descripcion")
        record.setValue(notification.fecha, forKey: "CD_fecha")
        record.setValue(notification.leido, forKey: "CD_leido")
        record.setValue(notification.type, forKey: "CD_type")
    }
    
    func setServiceCKRecordVariables(service: ServiceModel, record: CKRecord) {
        record.setValue(service.clientId, forKey: "CD_clientId")
        record.setValue(service.serviceId, forKey: "CD_serviceId")
        record.setValue(service.nombre, forKey: "CD_nombre")
        record.setValue(service.apellidos, forKey: "CD_apellidos")
        record.setValue(service.fecha, forKey: "CD_fecha")
        record.setValue(service.profesional, forKey: "CD_profesional")
        record.setValue(service.servicio, forKey: "CD_servicios")
        record.setValue(service.observacion, forKey: "CD_observacion")
        record.setValue(service.precio, forKey: "CD_precio")
    }
    
    func setCierreCajaCKRecordVariables(cierreCaja: CierreCajaModel, record: CKRecord) {
        record.setValue(cierreCaja.cajaId, forKey: "CD_cajaId")
        record.setValue(cierreCaja.fecha, forKey: "CD_fecha")
        record.setValue(cierreCaja.numeroServicios, forKey: "CD_numeroServicios")
        record.setValue(cierreCaja.totalCaja, forKey: "CD_totalCaja")
        record.setValue(cierreCaja.totalProductos, forKey: "CD_totalProductos")
        record.setValue(cierreCaja.efectivo, forKey: "CD_efectivo")
        record.setValue(cierreCaja.tarjeta, forKey: "CD_tarjeta")
    }
}
