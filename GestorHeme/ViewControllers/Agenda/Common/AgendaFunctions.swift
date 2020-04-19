//
//  AgendaFunctions.swift
//  GestorHeme
//
//  Created by jon mikel on 06/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class AgendaFunctions: NSObject {
    static func getBeginningOfDayFromDate(date: Date) -> Date {
        let calendar: Calendar = Calendar.current
        var components: DateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.hour = 8
        components.minute = 0
        components.second = 0
        
        return calendar.date(from: components)!
    }
    
    static func getEndOfDayFromDate(date: Date) -> Date {
        let calendar: Calendar = Calendar.current
        var components: DateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.hour = 20
        components.minute = 0
        components.second = 0
        
        return calendar.date(from: components)!
    }
    
    static func getHoursAndMinutesFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "es_ES")
        let string = dateFormatter.string(from: date)
        return string
    }
    
    static func getColorForProfesional(profesionalId: Int64) -> UIColor {
        if profesionalId == 0 {
            return .black
        }
        
        let empleado: EmpleadoModel = Constants.databaseManager.empleadosManager.getEmpleadoFromDatabase(empleadoId: profesionalId)
        
        return UIColor(cgColor: CGColor(srgbRed: CGFloat(empleado.redColorValue), green: CGFloat(empleado.greenColorValue), blue: CGFloat(empleado.blueColorValue), alpha: 1.0))
    }
    
    static func add15MinutesToDate(date: Date) -> Date {
        return Calendar.current.date(byAdding: .minute, value: 15, to: date)!
    }
    
    static func getMonthNameFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        dateFormatter.locale = Locale(identifier: "es_ES")
        return dateFormatter.string(from: date)
    }
    
    static func getCurrentWeekDayNameFromWeekDay(weekDay:Int) -> String {
        switch weekDay {
        case 2:
            return "Lun"
        case 3:
            return "Mar"
        case 4:
            return "Mier"
        case 5:
            return "Jue"
        case 6:
            return "Vie"
        case 7:
            return "Sab"
        default:
            return "Dom"
        }
    }
    
    static func getWeekDayFromDate(date: Date) -> Int {
         return Calendar.current.component(.weekday, from: date)
     }
    
    static func getNumberOfDaysBetweenDates(date1: Date, date2: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date1, to: date2).day!
    }
}
