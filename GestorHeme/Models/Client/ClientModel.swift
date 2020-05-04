//
//  ClientModel.swift
//  GestorHeme
//
//  Created by jon mikel on 01/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class ClientModel: NSObject {
    var id: Int64 = 0
    var nombre: String = ""
    var apellidos: String = ""
    var fecha: Int64 = 0
    var telefono: String = ""
    var email: String = ""
    var direccion: String = ""
    var cadenciaVisita: String = ""
    var observaciones: String = ""
    var notificacionPersonalizada: Int64 = 0
    var imagen: String = ""
}
