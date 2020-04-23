//
//  BirthdayModel.swift
//  GestorHeme
//
//  Created by jon mikel on 23/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import Foundation


class BirthdayModel: NSObject {
    var userId: Int64 = 0
    var nombre: String = ""
    var apellidos: String = ""
    
    init(userId: Int64, nombre: String, apellidos: String) {
        self.userId = userId
        self.nombre = nombre
        self.apellidos = apellidos
    }
}
