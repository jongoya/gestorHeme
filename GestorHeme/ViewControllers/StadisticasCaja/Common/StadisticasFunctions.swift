//
//  StadisticasFunctions.swift
//  GestorHeme
//
//  Created by jon mikel on 22/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import Foundation

class StadisticasFunctions {
    
    static func getCierreCajasAnual(cierres: [CierreCajaModel]) -> [CierreCajaModel] {
        var cierreCajasPorMes: [CierreCajaModel] = []
        
        for index in 1...12 {
            var cierreCajasMensual: [CierreCajaModel] = []
            for cierreCaja in cierres {
                let mes = AgendaFunctions.getMonthNumberFromDate(date: Date(timeIntervalSince1970: TimeInterval(cierreCaja.fecha)))
                if mes == index {
                    cierreCajasMensual.append(cierreCaja)
                }
            }
            
            if cierreCajasMensual.count > 0 {
                cierreCajasPorMes.append(sumarValores(cierreCajas: cierreCajasMensual))
            }
        }
        
        return cierreCajasPorMes
    }
    
    static func getCierreCajasTotal(cierres: [CierreCajaModel]) -> [CierreCajaModel] {
        var cierreCajasPorAño: [CierreCajaModel] = []
        let actualYear = AgendaFunctions.getYearNumberFromDate(date: Date())
        
        for index in (actualYear - 50)...(actualYear + 50) {
            var cierreCajasAnual: [CierreCajaModel] = []
            for cierreCaja in cierres {
                let año = AgendaFunctions.getYearNumberFromDate(date: Date(timeIntervalSince1970: TimeInterval(cierreCaja.fecha)))
                if año == index {
                    cierreCajasAnual.append(cierreCaja)
                }
            }
            if cierreCajasAnual.count > 0 {
                cierreCajasPorAño.append(sumarValores(cierreCajas: cierreCajasAnual))
            }
        }
        
        return cierreCajasPorAño
    }
    
    private static func sumarValores(cierreCajas: [CierreCajaModel]) -> CierreCajaModel {
        let cajaModel: CierreCajaModel = CierreCajaModel()
        var sumaNumeroServicios: Int = 0
        var sumaTotalCaja: Double = 0.0
        var sumaTotalProductos: Double = 0.0
        var sumaEfectivo: Double = 0.0
        var sumaTarjeta: Double = 0.0
        
        var fecha: Int64 = 0
        
        for cierreCaja in cierreCajas {
            fecha = cierreCaja.fecha
            sumaNumeroServicios = sumaNumeroServicios + cierreCaja.numeroServicios
            sumaTotalCaja = sumaTotalCaja + cierreCaja.totalCaja
            sumaTotalProductos = sumaTotalProductos + cierreCaja.totalProductos
            sumaEfectivo = sumaEfectivo + cierreCaja.efectivo
            sumaTarjeta = sumaTarjeta + cierreCaja.tarjeta
        }
        
        cajaModel.fecha = fecha
        cajaModel.numeroServicios = sumaNumeroServicios
        cajaModel.totalCaja = sumaTotalCaja
        cajaModel.totalProductos = sumaTotalProductos
        cajaModel.efectivo = sumaEfectivo
        cajaModel.tarjeta = sumaTarjeta
        
        return cajaModel
    }
}
