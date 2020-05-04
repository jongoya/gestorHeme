//
//  Constants.swift
//  GestorHeme
//
//  Created by jon mikel on 01/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class Constants: NSObject {
    
    //Constantes de cadencia
    static let unaSemana: String = "cada semana"
    static let dosSemanas: String = "cada 2 semanas"
    static let tresSemanas: String = "cada 3 semanas"
    static let unMes: String = "cada mes"
    static let unMesUnaSemana = "cada mes y 1 semana"
    static let unMesDosSemanas =  "cada mes y 2 semanas"
    static let unMesTresSemanas =  "cada mes y 3 semanas"
    static let dosMeses = "cada 2 meses"
    static let dosMesesYUnaSemana = "cada 2 meses y 1 semana"
    static let dosMesesYDosSemanas = "cada 2 meses y 2 semanas"
    static let dosMesesYTresSemanas = "cada 2 meses y 3 semanas"
    static let tresMeses = "cada 3 meses"
    static let masDeTresMeses = "mas de 3 meses"
    
    
    //Constantes tipo notificaciones
    static let notificacionCumpleIdentifier: String = "cumpleaños"
    static let notificacionCadenciaIdentifier: String = "cadencia"
    static let notificacionCajaCierreIdentifier: String = "cajaCierre"
    static let notificacionPersonalizadaIdentifier: String = "personalizada"
    
    //Constante del backup
    static let backupKey: String = "backup"
    
    static let databaseManager: DatabaseManager = DatabaseManager()
    static var rootController: RootViewController!
    static let cloudDatabaseManager: CloudDatabaseManager = CloudDatabaseManager()
}
