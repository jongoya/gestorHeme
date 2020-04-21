//
//  CajaModel.swift
//  GestorHeme
//
//  Created by jon mikel on 21/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import Foundation


class CierreCajaModel: NSObject {
    var cajaId: Int64 = 0
    var fecha: Int64 = 0
    var numeroServicios: Int = 0
    var totalCaja: Double = 0.0
    var totalProductos: Double = 0.0
    var efectivo: Double = 0.0
    var tarjeta: Double = 0.0
}
