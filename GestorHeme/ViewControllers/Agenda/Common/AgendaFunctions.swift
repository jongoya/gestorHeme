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
        components.hour = 23
        components.minute = 0
        components.second = 0
        
        return calendar.date(from: components)!
    }
    
    static func getBeginingOfYearFromDate(date: Date) -> Date {
        let calendar: Calendar = Calendar.current
        var components: DateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.month = 1
        components.day = 1
        components.hour = 1
        components.minute = 0
        components.second = 0
        
        return calendar.date(from: components)!
        
    }
    
    static func getEndOfYearFromDate(date: Date) -> Date {
        let calendar: Calendar = Calendar.current
        var components: DateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.month = 12
        components.day = 31
        components.hour = 23
        components.minute = 00
        components.second = 00
        
        return calendar.date(from: components)!
    }
    
    static func getBeginingOfMonthFromDate(date: Date) -> Date {
        let calendar: Calendar = Calendar.current
        var components: DateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.day = 1
        components.hour = 1
        components.minute = 00
        components.second = 00
        
        return calendar.date(from: components)!
    }
    
    static func getEndOfMonthFromDate(date: Date) -> Date {
        var components: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let range = Calendar.current.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        components.day = numDays
        components.hour = 23
        components.minute = 00
        components.second = 00
        return Calendar.current.date(from: components)!
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
        
        let empleado: EmpleadoModel = Constants.databaseManager.empleadosManager.getEmpleadoFromDatabase(empleadoId: profesionalId)!
        
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
    
    static func getMonthNumberFromDate(date: Date) -> Int {
        return Calendar.current.component(.month, from: date)
    }
    
    static func getYearNumberFromDate(date: Date) -> Int {
        return Calendar.current.component(.year, from: date)
    }
    
    /*static func checkIfSameYear(date1TimeStamp: Int64, date2TimeStamp: Int64) -> Bool {
        let date1: Date = Date(timeIntervalSince1970: TimeInterval(date1TimeStamp))
        let date2: Date = Date(timeIntervalSince1970: TimeInterval(date2TimeStamp))
        return Calendar.current.component(.year, from: date1) == Calendar.current.component(.year, from: date2)
    }*/
}
