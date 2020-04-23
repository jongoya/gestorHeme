//
//  StadisticaDetailCell.swift
//  GestorHeme
//
//  Created by jon mikel on 23/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class StadisticaDetailCell: UITableViewCell {
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var valorLabel: UILabel!
    
    func setupCell(stadisticaModel: StadisticaModel, isNumeroServicios: Bool, isMensual: Bool, isTotal: Bool) {
        valorLabel.text = isNumeroServicios ? String(Int(stadisticaModel.valor)) : String(format: "%.2f", stadisticaModel.valor) + " €"
        
        let year: Int = AgendaFunctions.getYearNumberFromDate(date: Date(timeIntervalSince1970: TimeInterval(stadisticaModel.fecha)))
        let month: String = AgendaFunctions.getMonthNameFromDate(date: Date(timeIntervalSince1970: TimeInterval(stadisticaModel.fecha))).capitalized
        let day: Int = Calendar.current.component(.day, from: Date(timeIntervalSince1970: TimeInterval(stadisticaModel.fecha)))
        
        if isMensual {
            fechaLabel.text = String(day) + " de " + month + " de " + String(year)
        }
        
        if !isMensual {
            fechaLabel.text = month + " de " + String(year)
        }
        
        if isTotal {
            fechaLabel.text = String(year)
        }
    }
}
