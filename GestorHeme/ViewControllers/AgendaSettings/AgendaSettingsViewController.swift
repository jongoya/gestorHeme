//
//  AgendaSettingsViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 11/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class AgendaSettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Agenda"
    }
}

extension AgendaSettingsViewController {
    @IBAction func didClickColoresButton(_ sender: Any) {
        performSegue(withIdentifier: "EmpleadosViewIdentifier", sender: nil)
    }
}

extension AgendaSettingsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmpleadosViewIdentifier" {
            let controller: EmpleadosViewController = segue.destination as! EmpleadosViewController
            controller.showColorView = true
        }
    }
}
