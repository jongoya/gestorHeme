//
//  CloudEmpleadoProtocol.swift
//  GestorHeme
//
//  Created by jon mikel on 20/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import Foundation

protocol CloudEmpleadoProtocol {
    func empleadoSincronizationFinished()
    func empleadoSincronizationError(error: String)
    func empleadoDeleted(empleado: EmpleadoModel)
}
