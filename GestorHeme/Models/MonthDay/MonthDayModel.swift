//
//  MonthDayModel.swift
//  GestorHeme
//
//  Created by jon mikel on 06/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import Foundation

class MonthDayModel: NSObject {
    var date: Date!
    var emptyState: Bool!
    
    init(date: Date, emptyState: Bool) {
        self.date = date
        self.emptyState = emptyState
    }
}
