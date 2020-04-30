//
//  TipoServiciosProtocol.swift
//  GestorHeme
//
//  Created by jon mikel on 20/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import Foundation

protocol CloudTipoServiciosProtocol {
    func tipoServiciosSincronizationFinished()
    func tipoServiciosSincronizationError(error: String)
}
