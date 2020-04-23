//
//  StadisticaModel.swift
//  GestorHeme
//
//  Created by jon mikel on 22/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import Foundation

class StadisticaModel {
    var fecha: Int64 = 0
    var valor: Double = 0.0
    
    init(fecha: Int64, valor: Double) {
        self.fecha = fecha
        self.valor = valor
    }
}
