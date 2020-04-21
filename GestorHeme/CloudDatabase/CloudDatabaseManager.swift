//
//  CloudDatabaseManager.swift
//  GestorHeme
//
//  Created by jon mikel on 16/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import CloudKit

class CloudDatabaseManager: NSObject {
    var clientManager: CloudClientManager!
    var serviceManager: CloudServiceManager!
    var notificationManager: CloudNotificationManager!
    var tipoServicioManager: CloudTipoServicioManager!
    var empleadoManager: CloudEmpleadoManager!
    var cierreCajaManager: CloudCierreCajaManager!
    
    override init() {
        super.init()
        clientManager = CloudClientManager()
        serviceManager = CloudServiceManager()
        notificationManager = CloudNotificationManager()
        tipoServicioManager = CloudTipoServicioManager()
        empleadoManager = CloudEmpleadoManager()
        cierreCajaManager = CloudCierreCajaManager()
    }
}
