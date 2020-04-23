//
//  AxisFormatter.swift
//  GestorHeme
//
//  Created by jon mikel on 22/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import Foundation
import Charts

class AxisFormatter: IAxisValueFormatter {
    var actualValue: Int = 0
    var isAnual: Bool!
    
    init(isAnual: Bool) {
        self.isAnual = isAnual
    }
    
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let newValue: Int = Int(value)
        if actualValue != newValue {
            actualValue = newValue
            return isAnual ? getMonthNameForMonthNumber(monthNumber: newValue) : String(newValue)
        }
        
        return ""
        
    }
    
    private func getMonthNameForMonthNumber(monthNumber: Int) -> String {
        switch monthNumber {
        case 1:
            return "Ene"
        case 2:
            return "Feb"
        case 3:
            return "Mar"
        case 4:
            return "Abr"
        case 5:
            return "May"
        case 6:
            return "Jun"
        case 7:
            return "Jul"
        case 8:
            return "Ago"
        case 9:
            return "Sep"
        case 10:
            return "Oct"
        case 11:
            return "Nov"
        default:
            return "Dic"
        }
    }
}
