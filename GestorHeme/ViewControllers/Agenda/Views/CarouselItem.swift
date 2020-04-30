//
//  CarouselItem.swift
//  GestorHeme
//
//  Created by jon mikel on 15/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class CarouselItem: UIView {
    var dayLabel: UILabel!
    var weekNameLabel: UILabel!
    var monthNameLabel: UILabel!
    var citasPoint: UIView!
    
    var itemWidth: CGFloat!
    var itemHeight: CGFloat!
    let horizontalMargin: CGFloat = 5
    let verticalMargin: CGFloat = 2
    let dayNumberWidth: CGFloat = 30
    var date: Date!
    var isToday: Bool = false

    init(frame: CGRect, date: Date) {
        super.init(frame: frame)
        itemWidth = frame.size.width
        itemHeight = frame.size.height
        self.date = date
        
        customizeView()
        
        isToday = Calendar.current.isDateInToday(date)
        
        addContentView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func customizeView() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.borderColor = UIColor.systemGray4.cgColor
        layer.borderWidth = 1
    }
    
    func highlightView() {
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 2
    }
    
    func unhightlightView() {
        layer.shadowOpacity = 0
        layer.shadowOffset = .zero
        layer.shadowRadius = 0
    }
    
    func addContentView() {
        addDayLabel()
        addDayOfTheWeekNameLabel()
        addMonthNameLabel()
        
        checkCitasPoint()
    }
    
    func checkCitasPoint() {
        if Constants.databaseManager.servicesManager.getServicesForDay(date: date).count > 0 {
            addCitasPointView()
        } else {
            if citasPoint != nil {
                citasPoint.removeFromSuperview()
                citasPoint = nil
            }
        }
    }
    
    func addDayLabel() {
        dayLabel = UILabel(frame: CGRect(x: (itemWidth - dayNumberWidth) / 2, y: verticalMargin, width: dayNumberWidth, height: 25))
        dayLabel.text = String(Calendar.current.component(.day, from: date))
        dayLabel.textColor = isToday ? .red : .black
        dayLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        dayLabel.textAlignment = .center
        addSubview(dayLabel)
    }
    
    func addDayOfTheWeekNameLabel() {
        weekNameLabel = UILabel(frame: CGRect(x: horizontalMargin, y: dayLabel.frame.size.height + dayLabel.frame.origin.y, width: itemWidth - horizontalMargin * 2, height: 20))
        weekNameLabel.text = AgendaFunctions.getCurrentWeekDayNameFromWeekDay(weekDay: AgendaFunctions.getWeekDayFromDate(date: date))
        weekNameLabel.textColor = isToday ? .red : .black
        weekNameLabel.font = UIFont.systemFont(ofSize: 15)
        weekNameLabel.textAlignment = .center
        addSubview(weekNameLabel)
    }
    
    func addMonthNameLabel() {
        monthNameLabel = UILabel(frame: CGRect(x: horizontalMargin, y: weekNameLabel.frame.size.height + weekNameLabel.frame.origin.y, width: itemWidth - horizontalMargin * 2, height: 15))
        monthNameLabel.text = AgendaFunctions.getMonthNameFromDate(date: date).capitalized
        monthNameLabel.textColor = isToday ? .red : .gray
        monthNameLabel.font = UIFont.systemFont(ofSize: 14)
        monthNameLabel.textAlignment = .center
        addSubview(monthNameLabel)
    }
    
    func addCitasPointView() {
        citasPoint = UIView(frame: CGRect(x: dayLabel.frame.origin.x + dayNumberWidth, y: 10, width: 8, height: 8))
        citasPoint.backgroundColor = .red
        citasPoint.layer.cornerRadius = citasPoint.frame.size.width / 2
        addSubview(citasPoint)
    }
}
