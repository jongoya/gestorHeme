//
//  CandenciaModel.swift
//  GestorHeme
//
//  Created by jon mikel on 24/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import Foundation

class CadenciaModel {
    var cadencia: String = ""
    var candenciaTime: Int64 = 0
    let numberOfExtraDays: Int = 20
    
    init(cadencia: String) {
        self.cadencia = cadencia
        self.candenciaTime = getCandeciaTimeForCadencia(cadencia: cadencia)
    }
    
    private func getCandeciaTimeForCadencia(cadencia: String) -> Int64 {
        switch cadencia {
        case Constants.unaSemana:
            return cadenciaFor1Semana()
        case Constants.dosSemanas:
            return cadenciaFor2Semanas()
        case Constants.tresSemanas:
            return cadenciaFor3Semanas()
        case Constants.unMes:
            return cadenciaFor1Mes()
        case Constants.unMesUnaSemana:
            return cadenciaFor1Mes1Semana()
        case Constants.unMesDosSemanas:
            return cadenciaFor1Mes2Semanas()
        case Constants.unMesTresSemanas:
            return cadenciaFor1Mes3Semanas()
        case Constants.dosMeses:
            return cadenciaFor2Meses()
        case Constants.dosMesesYUnaSemana:
            return cadenciaFor2Meses1Semana()
        case Constants.dosMesesYDosSemanas:
            return cadenciaFor2Meses2Semanas()
        case Constants.dosMesesYTresSemanas:
            return cadenciaFor2Meses3Semanas()
        case Constants.tresMeses:
            return cadenciaFor3Meses()
        default:
            return cadenciaForMasDe3Meses()
        }
    }
    
    private func cadenciaFor1Semana() -> Int64 {
        var dateComponent = DateComponents()
        dateComponent.day = -7 - numberOfExtraDays
        return Int64(Calendar.current.date(byAdding: dateComponent, to: Date())!.timeIntervalSince1970)
    }
    
    private func cadenciaFor2Semanas() -> Int64 {
        var dateComponent = DateComponents()
        dateComponent.day = -15 - numberOfExtraDays
        return Int64(Calendar.current.date(byAdding: dateComponent, to: Date())!.timeIntervalSince1970)
    }
    
    private func cadenciaFor3Semanas() -> Int64 {
        var dateComponent = DateComponents()
        dateComponent.day = -21 - numberOfExtraDays
        return Int64(Calendar.current.date(byAdding: dateComponent, to: Date())!.timeIntervalSince1970)
    }
    
    private func cadenciaFor1Mes() -> Int64 {
        var dateComponent = DateComponents()
        dateComponent.day = -30 - numberOfExtraDays
        return Int64(Calendar.current.date(byAdding: dateComponent, to: Date())!.timeIntervalSince1970)
    }
    
    private func cadenciaFor1Mes1Semana() -> Int64 {
        var dateComponent = DateComponents()
        dateComponent.day = -37 - numberOfExtraDays
        return Int64(Calendar.current.date(byAdding: dateComponent, to: Date())!.timeIntervalSince1970)
    }
    
    private func cadenciaFor1Mes2Semanas() -> Int64 {
        var dateComponent = DateComponents()
        dateComponent.day = -45 - numberOfExtraDays
        return Int64(Calendar.current.date(byAdding: dateComponent, to: Date())!.timeIntervalSince1970)
    }
    
    private func cadenciaFor1Mes3Semanas() -> Int64 {
        var dateComponent = DateComponents()
        dateComponent.day = -51 - numberOfExtraDays
        return Int64(Calendar.current.date(byAdding: dateComponent, to: Date())!.timeIntervalSince1970)
    }
    
    private func cadenciaFor2Meses() -> Int64 {
        var dateComponent = DateComponents()
        dateComponent.day = -60 - numberOfExtraDays
        return Int64(Calendar.current.date(byAdding: dateComponent, to: Date())!.timeIntervalSince1970)
    }
    
    private func cadenciaFor2Meses1Semana() -> Int64 {
        var dateComponent = DateComponents()
        dateComponent.day = -67 - numberOfExtraDays
        return Int64(Calendar.current.date(byAdding: dateComponent, to: Date())!.timeIntervalSince1970)
    }
    
    private func cadenciaFor2Meses2Semanas() -> Int64 {
        var dateComponent = DateComponents()
        dateComponent.day = -75 - numberOfExtraDays
        return Int64(Calendar.current.date(byAdding: dateComponent, to: Date())!.timeIntervalSince1970)
    }
    
    private func cadenciaFor2Meses3Semanas() -> Int64 {
        var dateComponent = DateComponents()
        dateComponent.day = -81 - numberOfExtraDays
        return Int64(Calendar.current.date(byAdding: dateComponent, to: Date())!.timeIntervalSince1970)
    }
    
    private func cadenciaFor3Meses() -> Int64 {
        var dateComponent = DateComponents()
        dateComponent.day = -90 - numberOfExtraDays
        return Int64(Calendar.current.date(byAdding: dateComponent, to: Date())!.timeIntervalSince1970)
    }
    
    private func cadenciaForMasDe3Meses() -> Int64 {
        var dateComponent = DateComponents()
        dateComponent.day = -97 - numberOfExtraDays
        return Int64(Calendar.current.date(byAdding: dateComponent, to: Date())!.timeIntervalSince1970)
    }
}
