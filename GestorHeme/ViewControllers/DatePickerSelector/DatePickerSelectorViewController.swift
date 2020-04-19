//
//  DatePickerSelectorViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 02/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class DatePickerSelectorViewController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var delegate: DatePickerSelectorProtocol!
    var datePickerMode: UIDatePicker.Mode!
    var initialDate: Int64 = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fecha"
        
        datePicker.datePickerMode = datePickerMode
        
        if initialDate != 0 {
            datePicker.setDate(Date(timeIntervalSince1970: TimeInterval(initialDate)), animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate.dateSelected(date: datePicker.date)
    }
}
