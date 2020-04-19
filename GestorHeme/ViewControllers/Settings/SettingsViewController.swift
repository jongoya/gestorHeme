//
//  SettingsViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 10/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ajustes"
    }
}

extension SettingsViewController {
    @IBAction func didClickEmpleados(_ sender: Any) {
        performSegue(withIdentifier: "EmpleadosViewIdentifier", sender: nil)
    }
    
    @IBAction func didClickServicios(_ sender: Any) {
        performSegue(withIdentifier: "ServiciosIdentifier", sender: nil)
    }
    
    @IBAction func didClickCalendar(_ sender: Any) {
        performSegue(withIdentifier: "AgendaSettingsIdentifier", sender: nil)
    }
}

extension SettingsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmpleadosViewIdentifier" {
            let controller: EmpleadosViewController = segue.destination as! EmpleadosViewController
            controller.showColorView = false
        }
    }
}
