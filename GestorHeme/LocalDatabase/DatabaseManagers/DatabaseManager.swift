//
//  DatabaseManager.swift
//  GestorHeme
//
//  Created by jon mikel on 01/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import CoreData

class DatabaseManager: NSObject {
    
    var clientsManager: ClientesManager!
    var servicesManager: ServicesManager!
    var notificationsManager: NotificationsManager!
    var empleadosManager: EmpleadosManager!
    var tipoServiciosManager: TipoServiciosManager!
    var cierreCajaManager: CierreCajaManager!
    
    override init() {
        super.init()
        clientsManager = ClientesManager()
        servicesManager = ServicesManager()
        notificationsManager = NotificationsManager()
        empleadosManager = EmpleadosManager()
        tipoServiciosManager = TipoServiciosManager()
        cierreCajaManager = CierreCajaManager()
    }
}
